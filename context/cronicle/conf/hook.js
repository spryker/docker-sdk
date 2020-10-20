#!/usr/bin/env node

var path = require('path');
var cp = require('child_process');
var os = require('os');
var fs = require('fs');
var async = require('async');
var bcrypt = require('bcrypt-node');

var Args = require('pixl-args');
var Tools = require('pixl-tools');
var StandaloneStorage = require('pixl-server-storage/standalone');

// chdir to the proper server root dir
process.chdir(path.dirname(__dirname));

// load app's config file
var config = require('../conf/config.json');

// shift commands off beginning of arg array
var argv = JSON.parse(JSON.stringify(process.argv.slice(2)));
var commands = [];
while (argv.length && !argv[0].match(/^\-/)) {
    commands.push(argv.shift());
}

// now parse rest of cmdline args, if any
var args = new Args(argv, {
    debug: false,
    verbose: false,
    quiet: false
});
args = args.get(); // simple hash

// copy debug flag into config (for standalone)
config.Storage.debug = args.debug;

var print = function (msg) {
    // print message to console
    if (!args.quiet) process.stdout.write(msg);
};
var verbose = function (msg) {
    // print only in verbose mode
    if (args.verbose) print(msg);
};
var warn = function (msg) {
    // print to stderr unless quiet
    if (!args.quiet) process.stderr.write(msg);
};
var verbose_warn = function (msg) {
    // verbose print to stderr unless quiet
    if (args.verbose && !args.quiet) process.stderr.write(msg);
};

if (config.uid && (process.getuid() != 0)) {
    print("ERROR: Must be root to use this script.\n");
    process.exit(1);
}

// determine server hostname
var hostname = (process.env['HOSTNAME'] || process.env['HOST'] || os.hostname()).toLowerCase();

// find the first external IPv4 address
var ip = '';
var ifaces = os.networkInterfaces();
var addrs = [];
for (var key in ifaces) {
    if (ifaces[key] && ifaces[key].length) {
        Array.from(ifaces[key]).forEach(function (item) {
            addrs.push(item);
        });
    }
}
var addr = Tools.findObject(addrs, {family: 'IPv4', internal: false});
if (addr && addr.address && addr.address.match(/^\d+\.\d+\.\d+\.\d+$/)) {
    ip = addr.address;
} else {
    print("ERROR: Could not determine server's IP address.\n");
    process.exit(1);
}

// util.isArray is DEPRECATED??? Nooooooooode!
var isArray = Array.isArray || util.isArray;

// prevent logging transactions to STDOUT
config.Storage.log_event_types = {};

// allow APPNAME_key env vars to override config
var env_regex = new RegExp("^CRONICLE_(.+)$");
for (var env_key in process.env) {
    if (env_key.match(env_regex)) {
        var env_path = RegExp.$1.trim().replace(/^_+/, '').replace(/_+$/, '').replace(/__/g, '/');
        var env_value = process.env[env_key].toString();

        // massage value into various types
        if (env_value === 'true') env_value = true;
        else if (env_value === 'false') env_value = false;
        else if (env_value.match(/^\-?\d+$/)) env_value = parseInt(env_value);
        else if (env_value.match(/^\-?\d+\.\d+$/)) env_value = parseFloat(env_value);

        Tools.setPath(config, env_path, env_value);
    }
}

// construct standalone storage server
var storage = new StandaloneStorage(config.Storage, function (err) {
    if (err) throw err;
    // storage system is ready to go

    // become correct user
    if (config.uid && (process.getuid() == 0)) {
        verbose("Switching to user: " + config.uid + "\n");
        process.setuid(config.uid);
    }

    // custom job data expire handler
    storage.addRecordType('cronicle_job', {
        'delete': function (key, value, callback) {
            storage.delete(key, function (err) {
                storage.delete(key + '/log.txt.gz', function (err) {
                    callback();
                }); // delete
            }); // delete
        }
    });

    // process command
    var cmd = commands.shift();

    verbose("\n");

    console.log('=========');
    console.log('bbb');
    console.log('=========');
    console.log(cmd);
    console.log('=========');
    switch (cmd) {
        case 'before-start':
            let scheduledEventIds = {};
            storage.listGet( 'global/schedule', parseInt(0), parseInt(0), function(err, items, list) {
                for (let i = 0; i <= items.length; i++) {
                    if (items[i] != null) {
                        scheduledEventIds[items[i].id] = items[i].title;
                        items[i].enabled = 0;
                        storage.listFindUpdate( 'global/schedule', { id: items[i].id }, items[i], function(err) {
                            if (err) {
                                print("Failed to update event: " + err);
                            }
                        });
                    }
                }
            });

            let globalCategories = {};

            storage.listGet( 'global/categories', parseInt(0), parseInt(0), function(err, items, list) {
                for (let i = 0; i <= items.length; i++) {
                    if (items[i] != null) {
                        globalCategories[items[i].id] = items[i].title;
                    }
                }
            });

            const schedulerDataReader = cp.spawn(
                'vendor/bin/console', ['scheduler:export', process.env.SPRYKER_CURRENT_SCHEDULER || 'cronicle'],
                {
                    cwd: '/data',
                }
            );

            let jobs = '';
            let errors = '';
            schedulerDataReader.stdout.on('data', (data) => {
                jobs += String(data);
            });
            schedulerDataReader.stderr.on('data', (data) => {
                errors += String(data);
            });
            schedulerDataReader.on('close', (code) => {
                if (code > 0) {
                    console.error(errors);
                    process.exit(1);
                }

                let events = JSON.parse(jobs.substring(Math.min(jobs.indexOf("["), jobs.indexOf("{"))));

                var categories = {};

                for (var key in events) {
                    let cat = {
                        'max_children': 0,
                        'enabled': 1
                    };
                    let event = JSON.parse(JSON.stringify(events[key]));
                    let categoryTitle = event.title.split('__')[0].toString().replace(/\W+/g, '');

                    if (categories.hasOwnProperty(categoryTitle)) {
                        cat.id = event.category = categories[categoryTitle];
                        cat.title = categoryTitle;
                    }

                    if (event.category === null) {
                        cat.title = categoryTitle;
                        cat.id = categories[categoryTitle] = event.category = categoryTitle.toString().toLowerCase().replace(/\W+/g, '');
                    }

                    if (!globalCategories[cat.id]) {
                        storage.listUnshift('global/categories', cat, function (err) {
                            if (err) {
                                print('category', "Failed to create category: " + err);
                            }
                        });
                        globalCategories[cat.id] = cat.title;
                    }

                    event.id = event.title.toString().toLowerCase().replace(/\W+/g, '');

                    if (scheduledEventIds[event.id]) {
                        storage.listFindUpdate( 'global/schedule', { id: event.id }, event, function(err) {
                            if (err) {
                                print("Failed to update event: " + err);
                            }
                        });
                    } else {
                        storage.listUnshift('global/schedule', event, function (err) {
                            if (err) {
                                print("Failed to create event: " + err);
                            }
                        });
                    }
                }
            });

            schedulerDataReader.stderr.on('data', (data) => {
                console.error(`stderr: ${data}`);
            });
            break;

        default:
            print("Unknown hook: " + cmd + "\n");
            storage.shutdown(function () {
                process.exit(0);
            });
            break;
    }
});
