const chokidar = require('chokidar');
const eol = require('eol');
const fs = require('fs');
const {promisify} = require('util');

const openAsync = promisify(fs.open);
const readAsync = promisify(fs.read);
const statAsync = promisify(fs.stat);

async function startFileWatcher(
    connection,
    streamName,
    inputPath,
    watcher,
) {
    const fileSizes = {}
    const fileDescriptors = {};

    const message = async function (
        sourceName,
        filePath,
        newSize,
        oldSize,
    ) {
        let fileDescriptor = fileDescriptors[filePath]
        if (!fileDescriptor) {
            fileDescriptor = await openAsync(inputPath + '/' + filePath, 'r')
            fileDescriptors[filePath] = fileDescriptor
        }
        const offset = newSize - oldSize;
        if (offset <= 0) {
            return;
        }
        const readBuffer = Buffer.alloc(offset)
        await readAsync(fileDescriptor, readBuffer, 0, offset, oldSize)
        const messages = eol.split(readBuffer.toString()).filter((msg) => !!msg.trim())
        messages.forEach((message) => {
            connection.write(`+msg|${streamName}|${sourceName}|${message}\0`)
        })
    }

    watcher.on('add', async (filePath) => {
        const sourceName = filePath + "";
        console.log(`[LOGGER] File added: ${filePath}`);
        fileSizes[filePath] = (await statAsync(inputPath + '/' + filePath)).size;
        connection.write(`+input|${streamName}|${sourceName}\0`)
    })

    watcher.on('change', async (filePath) => {
        const sourceName = filePath + "";
        try {
            const newSize = (await statAsync(inputPath + '/' + filePath)).size
            await message(
                sourceName,
                filePath,
                newSize,
                fileSizes[filePath],
            )
            fileSizes[filePath] = newSize
        } catch (err) {
            console.error(err)
        }
    })

    watcher.on('unlink', (filePath) => {
        const sourceName = filePath + "";
        delete fileSizes[filePath];
        delete fileDescriptors[filePath];
        console.log(`[LOGGER] File removed: ${filePath}`);
        connection.write(`-input|${streamName}|${sourceName}\0`)
    })
}

const FileWatcher = function (connection, streamName, path, options) {

    const defaults = {
        "depth": 99,
        "cwd": path,
    }

    const watcher = chokidar.watch(
        path + '/**/*.log',
        {...defaults, ...(options || {})},
    )

    startFileWatcher(
        connection,
        streamName,
        path,
        watcher,
    )

    return watcher;
}

module.exports = FileWatcher
