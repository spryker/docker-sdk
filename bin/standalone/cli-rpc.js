// ATTENTION: THIS CAN BE USED ONLY IN DEVELOPMENT.

const http = require('http');
const {spawn} = require('child_process');

class Server {

    constructor() {
        this._server = http.createServer(this._onRequest.bind(this));
    }

    listen(port, host) {
        port = port || 80;
        host = host || '0.0.0.0';

        this._server.listen(port, host, () => {
            console.log(`[INIT] Server is running at http://${host}:${port}/`);
        });
    }

    _onRequest(request, response) {
        response.setHeader('Content-Type', 'text/plain');

        this._readRequest(request, response, requestBody => {

            let child;
            try {
                child = spawn('bash', ['-c', requestBody]);
            } catch (error) {
                console.error(error);
                response.write(error.message);
                response.statusCode = 400;
                response.end();
                return;
            }

            console.info(requestBody);
            child.stdout.on('data', (chunk) => {
                response.write(chunk.toString());
            });
            child.on('close', (code) => {
                response.statusCode = code === 0 ? 200 : 400;
                response.end();
            });

            child.on('error', (error) => {
                console.error(error);
                response.write(error.message);
                response.statusCode = 400;
                response.end();
            });
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

const server = new Server();

server.listen(9000, '0.0.0.0');
