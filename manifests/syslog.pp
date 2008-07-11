
define collectd::syslog() {
	collectd::plugin {
		'syslog':
			lines => [ "LogLevel ${name}" ]
	}
}

