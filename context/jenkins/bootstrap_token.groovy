import jenkins.model.Jenkins
import hudson.model.User
import java.nio.file.*
import java.nio.charset.StandardCharsets
import groovy.transform.Field   // <<< IMPORTANT

// ===== env / dynamic path =====
@Field final String REGION    = System.getenv('AWS_REGION') ?: 'unknown-region'
@Field final String PROJECT   = System.getenv('SPRYKER_PROJECT_NAME') ?: 'unknown-project'
@Field final List<String> SSM_PARAMS = [
  "/${PROJECT}/base_task_definition/SPRYKER_SCHEDULER_PASSWORD",
  "/${PROJECT}/codebuild/base_task_definition/SPRYKER_SCHEDULER_PASSWORD",
]

// Jenkins user to mint token for
@Field final String USERNAME = System.getenv('SPRYKER_SCHEDULER_USER') ?: 'svc-spryker'
@Field final String LABEL    = "bootstrap-" + System.currentTimeMillis()

// Jenkins home as a Path
@Field final Path HOME     = (Jenkins.getInstanceOrNull() != null ? Jenkins.get().getRootDir().toPath()
                              : Paths.get(System.getenv('JENKINS_HOME') ?: "/var/jenkins_home"))
@Field final Path OUT_DIR  = HOME.resolve('secrets').resolve('bootstrap')
@Field final Path OUT_FILE = OUT_DIR.resolve("${USERNAME}.token")
Files.createDirectories(OUT_DIR)

// ---- marker to signal completion to entrypoint ----
@Field final Path MARKER_DIR  = OUT_DIR
@Field final Path MARKER_FILE = MARKER_DIR.resolve(".token_ready")

def writeMarker() {
  try {
    Files.createDirectories(this.@MARKER_DIR)
    Files.write(
      this.@MARKER_FILE,
      ("ready@" + new Date().toString() + "\n").getBytes("UTF-8"),
      StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING
    )
    try {
      def perms = [
        java.nio.file.attribute.PosixFilePermission.OWNER_READ,
        java.nio.file.attribute.PosixFilePermission.OWNER_WRITE
      ] as Set
      Files.setPosixFilePermissions(this.@MARKER_FILE, perms)
    } catch (Throwable ignore) {}
    println "[bootstrap] wrote marker: ${this.@MARKER_FILE}"
  } catch (Throwable t) {
    println "[bootstrap] WARNING: failed to write marker ${this.@MARKER_FILE}: ${t.message}"
  }
}

// ---- resolve ApiTokenProperty class safely (handles package differences)
Class apiTokenPropertyClass
try {
  apiTokenPropertyClass = Class.forName('jenkins.security.apitoken.ApiTokenProperty')
} catch (Throwable ignore) {
  apiTokenPropertyClass = Class.forName('jenkins.security.ApiTokenProperty') // older cores
}

// ===== helpers =====
def sh(Map<String,String> env, String cmd) {
  def pb = new ProcessBuilder(["bash","-lc", cmd]).redirectErrorStream(true)
  if (env) pb.environment().putAll(env)
  def p = pb.start()
  String out = p.inputStream.getText(StandardCharsets.UTF_8.name()).trim()
  int rc = p.waitFor()
  [rc: rc, out: out]
}

def writeTokenFile(Path outFile, String uuid, String value) {
  String content = (uuid ? "tokenUuid=${uuid}\n" : "") + "tokenValue=${value}\n"
  Files.write(outFile, content.getBytes('UTF-8'),
    StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING)
  try {
    def perms = [
      java.nio.file.attribute.PosixFilePermission.OWNER_READ,
      java.nio.file.attribute.PosixFilePermission.OWNER_WRITE
    ] as Set
    Files.setPosixFilePermissions(outFile, perms)
  } catch (Throwable ignore) {}
}

// publish to all target params
def publishToSSM(String value) {
  if (!value) return
  final String region  = this.@REGION
  final String project = this.@PROJECT
  if (!region || project == 'unknown-project') {
    println "[bootstrap] Skipping SSM (REGION/PROJECT not set): REGION=${region} PROJECT=${project}"
    return
  }
  this.@SSM_PARAMS.each { String param ->
    def r = sh([TOKEN_VALUE: value, AWS_REGION: region],
      'aws ssm put-parameter --region "$AWS_REGION" --name "'+param+'" --type SecureString --overwrite --value "$TOKEN_VALUE"')
    println "[bootstrap] SSM put-parameter rc=${r.rc} -> ${param}"
    if (r.rc != 0) {
      println "[bootstrap] WARNING: aws cli returned non-zero; output:\n${r.out}"
    }
  }
}

// ===== main flow =====
String tokenValue
String tokenUuid = null

// If local file already exists, re-publish that token and exit (no re-mint)
if (Files.exists(OUT_FILE)) {
  def m = (Files.readString(OUT_FILE, StandardCharsets.UTF_8) =~ /(?m)^tokenValue=(.+)$/)
  if (m.find()) {
    tokenValue = m.group(1).trim()
//     publishToSSM(tokenValue)  // enable if you want to re-publish
    println "[bootstrap] token file exists at ${OUT_FILE}; skipping generation"
    writeMarker()
    return
  } else {
    println "[bootstrap] token file exists but tokenValue not found; will generate a new token"
  }
}

// Create or load user
def u = User.getById(USERNAME, true)

// Ensure the ApiTokenProperty exists
def p = u.getProperty(apiTokenPropertyClass as Class)
if (p == null) {
  p = apiTokenPropertyClass.getDeclaredConstructor().newInstance()
  u.addProperty(p)
  u.save()
}

// ===== generate & extract token (getter-or-field tolerant) =====
def tokenStore = p.getClass().getMethod('getTokenStore').invoke(p)
def t = tokenStore.getClass().getMethod('generateNewToken', String).invoke(tokenStore, LABEL)

// Helper: try getter, Groovy property, then direct field
def readProp = { obj, List<String> names ->
  for (String n : names) {
    try { def m = obj.getClass().getMethod(n); def v = m.invoke(obj); if (v != null) return v.toString() } catch (Throwable ignore) {}
    try { def v = obj."$n"; if (v != null) return v.toString() } catch (Throwable ignore) {}
    try {
      def fName = n.startsWith('get') ? n.substring(3,4).toLowerCase() + n.substring(4) : n
      def f = obj.getClass().getDeclaredField(fName); f.setAccessible(true)
      def v = f.get(obj); if (v != null) return v.toString()
    } catch (Throwable ignore) {}
  }
  return null
}

tokenValue = readProp(t, ['getPlainValue','plainValue','getValue','value'])
tokenUuid  = readProp(t, ['getTokenUuid','tokenUuid','getUuid','uuid'])

if (!tokenValue) {
  try {
    def legacy = p.getClass().getMethod('getApiToken').invoke(p)
    if (legacy) tokenValue = legacy.toString()
  } catch (Throwable ignore) {}
}

if (!tokenValue) {
  println "[bootstrap] token class: ${t.getClass().name}"
  println "[bootstrap] methods: " + (t.getClass().getMethods()*.name.toSet().toList().sort().join(', '))
  println "[bootstrap] fields: " + (t.getClass().getDeclaredFields()*.name.toList().sort().join(', '))
  throw new RuntimeException("Could not read plain token value from Jenkins")
}

// Write local file and (optionally) update SSM
writeTokenFile(OUT_FILE, tokenUuid, tokenValue)
println "[bootstrap] generated API token for ${USERNAME}; wrote ${OUT_FILE}"
println "[bootstrap] updating ONLY ${SSM_PARAM}"
// publishToSSM(tokenValue)  // uncomment to push to SSM here

// mark completion so entrypoint can proceed
writeMarker()
