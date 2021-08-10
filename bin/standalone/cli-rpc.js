// ATTENTION: THIS CAN BE USED ONLY IN DEVELOPMENT.

const fs = require('fs');
const http = require('http');
const {promisify} = require('util');
const {spawn} = require('child_process');

class Dispatcher {

    dispatch(request, response, requestBody) {
        const command = '_' + request.method.toLowerCase() +  '_' + request.url.replace(/[^a-zA-Z0-9]/g, "");

        if (typeof this[command] !== 'undefined') {
            this[command](request, response, requestBody);
            return true;
        }

        response.statusCode = 404;
        response.end();

        return false;
    }

    _post_console(request, response, requestBody) {

        response.setHeader('Content-Type', 'text/plain');

        let child;
        let responseBuffer = '';

        try {
            child = spawn('bash', ['-c', requestBody]);
        } catch (error) {
            console.error(error);
            response.statusCode = 400;
            response.write(error.message);
            response.end();
            return;
        }

        console.info(requestBody);
        child.stdout.on('data', (chunk) => {
            responseBuffer += chunk.toString();
        });
        child.stderr.on('data', (chunk) => {
            responseBuffer += chunk.toString();
        });
        child.on('close', (code) => {
            response.statusCode = code === 0 ? 200 : 400;
            response.write(responseBuffer);
            response.end();
        });

        child.on('error', (error) => {
            console.error(error);
            response.statusCode = 400;
            response.write(error.message);
            response.end();
        });
    }

    _options_glueSchema(request, response) {
        response.setHeader('Access-Control-Allow-Origin', '*');
        response.setHeader('Access-Control-Allow-Methods', 'GET');
        response.statusCode = 201;
        response.end();
    }

    _get_glueSchema(request, response) {
        const fileLocation = process.env.SPRYKER_REST_API_SCHEMA_PATH || 'src/Generated/Glue/Specification/spryker_rest_api.schema.yml';
        const baseUrl = request.headers['x-schema-base-url'] || '';

        fs.readFile(process.env.PWD + '/' + fileLocation, 'utf8', function (error,schemaContent) {

            response.setHeader('Access-Control-Allow-Origin', '*');
            response.setHeader('Access-Control-Allow-Methods', 'GET');

            if (error) {
                response.setHeader('Content-Type', 'text/plain');
                response.statusCode = 500;
                response.write(error.toString());
                response.end();
                return;
            }

            if (baseUrl !== '') {
                schemaContent = schemaContent.replace(/(servers:\s*-\s*url:\s*['"])[^'"]*?(['"])/gm, '$1' + baseUrl + '$2');
            }

            response.setHeader('Content-Type', 'text/yaml');
            response.statusCode = 200;
            response.write(schemaContent);
            response.end();
        });
    }
}

class Server {

    constructor(dispatcher) {
        this._server = http.createServer(this._onRequest.bind(this));
        this._dispatcher = dispatcher;
    }

    listen(port, host) {
        port = port || 80;
        host = host || '0.0.0.0';

        this._server.listen(port, host, () => {
            console.log(`[INIT] Server is running at http://${host}:${port}/`);
        });
    }

    _onRequest(request, response) {
        this._readRequest(request, response, requestBody => {
            this._dispatcher.dispatch(request, response, requestBody);
        });
    }

    _readRequest(request, response, callback) {
        let body = '';
        request.on('error', (err) => {
            console.error(err);
        }).on('data', (chunk) => {
            body += chunk;
        }).on('end', () => {

            response.on('error', (err) => {
                console.error(err);
            });

            callback(body);
        });
    }
}

class Logger {
    async add(pipeName, destinationStream) {
        console.log(`[INIT] Creating fifo: ${pipeName}`)
        if (!fs.existsSync(pipeName)) {
            await spawn('mkfifo', [pipeName]);
            console.log(`[INIT] Created fifo: ${pipeName}`)
        }

        const pipeHandle = await promisify(fs.open)(pipeName, fs.constants.O_RDWR);
        const stream = fs.createReadStream(null, {fd: pipeHandle, autoClose: false});

        stream.pipe(destinationStream);
        console.log(`[INIT] Piping ${pipeName}`)
    }
}

const server = new Server(new Dispatcher());
server.listen(9000, '0.0.0.0');

const logger = new Logger();
logger.add(process.env.SPRYKER_LOG_STDOUT, process.stdout);
logger.add(process.env.SPRYKER_LOG_STDERR, process.stderr);
