settings {
	statusFile = "/tmp/backup.lsyncd.stat",
	statusInterval = 1,
}

directSync = {
	-- based on default rsync.
	default.rsync,
    delay = 10,
    maxProcesses = 1,

    init = function
    (
    	event
    )

        log(
            'Normal',
            'NO-START'
        )

        local inlet = event.inlet
        inlet.discardEvent(event);

    end,

    action = function
    (
        inlet
    )

        local event = inlet.getEvent( )
        log(
            'Normal',
            'EVENT-MY: \n',
            event.etype
        )

        return default.rsync.action(inlet)

    end,
}

sync {
    directSync,
    source = "/data",
    target = "/sync",
    delay = 10,
	filter = {
        '- /mutagen.*',
        '- /.unison',
        '- /.docker-sync',
        '- /.idea',
        '- /.project',
        '- /.composer',
        '- /.npm',
        '- /data/*/cache',
        '- /docker',
        '- /vendor/composer',
        '+ /vendor/composer/*.php',
        '+ /vendor/composer/xdebug-*',
	},
}
