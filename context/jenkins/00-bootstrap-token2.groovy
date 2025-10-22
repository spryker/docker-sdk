import jenkins.model.Jenkins
import hudson.model.User
import java.nio.file.*

def username = 'svc-spryker'
def label    = 'bootstrap-' + System.currentTimeMillis()

def home   = System.getenv('JENKINS_HOME') ?: Jenkins.instance.rootDir.absolutePath
def outDir = Paths.get(home, 'secrets', 'bootstrap')
Files.createDirectories(outDir)
def out    = outDir.resolve('svc-spryker.token')

try {
  if (Files.exists(out)) { println "[bootstrap] token file exists at ${out} — skipping"; return }

  // Resolve ApiTokenProperty class (new + legacy)
  Class apiTokenPropertyClass
  try {
    apiTokenPropertyClass = Class.forName('jenkins.security.apitoken.ApiTokenProperty')
    println "[bootstrap] using jenkins.security.apitoken.ApiTokenProperty"
  } catch (Throwable ignore) {
    apiTokenPropertyClass = Class.forName('jenkins.security.ApiTokenProperty')
    println "[bootstrap] using jenkins.security.ApiTokenProperty (legacy)"
  }

  // Ensure user + property
  def u = User.getById(username, true)
  def p = u.getProperty(apiTokenPropertyClass as Class)
  if (p == null) {
    p = apiTokenPropertyClass.getDeclaredConstructor().newInstance()
    u.addProperty(p)
    u.save()
  }

  // Mint token
  def tokenStore = p.getClass().getMethod('getTokenStore').invoke(p)
  def t          = tokenStore.getClass().getMethod('generateNewToken', String).invoke(tokenStore, label)

  // Extract values across versions without hard failing
  def methodNames = (t.getClass().methods*.name as Set)
  def tokenValue  = methodNames.contains('getPlainValue') ? t.getClass().getMethod('getPlainValue').invoke(t)
                    : (t.hasProperty('plainValue') ? t.plainValue : null)
  if (tokenValue == null) throw new RuntimeException('Cannot resolve plain token value')

  def tokenUuid = methodNames.contains('getTokenUuid') ? t.getClass().getMethod('getTokenUuid').invoke(t)
                  : (methodNames.contains('getUuid')   ? t.getClass().getMethod('getUuid').invoke(t)
                  : (t.hasProperty('tokenUuid') ? t.tokenUuid
                  : (t.hasProperty('uuid') ? t.uuid : null)))

  def content = (tokenUuid ? "tokenUuid=${tokenUuid}\n" : "") + "tokenValue=${tokenValue}\n"
  Files.write(out, content.getBytes('UTF-8'),
    StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING)

  println "[bootstrap] wrote token file to ${out}"
} catch (Throwable ex) {
  // Never crash Jenkins on bootstrap issues
  println "[bootstrap][ERROR] ${ex.class.name}: ${ex.message}"
}
