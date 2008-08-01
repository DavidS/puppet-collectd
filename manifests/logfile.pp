
define collectd::logfile($level, $timestamp = 'true') {
	collectd::plugin {
		"logfile_${name}":
			lines => [
				"File \"/var/log/collectd_${name}.log\"",
				"Timestamp ${timestamp}",
				"LogLevel ${level}"
			]
	}
}

