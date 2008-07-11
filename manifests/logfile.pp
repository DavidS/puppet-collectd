
define collectd::logfile($level, $timestamp = 'true') {
	collectd::plugin {
		'logfile':
			lines => [
				"File \"/var/log/collectd_${name}.log\",
				"Timestamp ${timestamp}",
				"LogLevel ${loglevel}"
			}
	}
}

