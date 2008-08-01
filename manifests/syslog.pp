# Define: collectd::syslog
# A shortcut to specifying the syslog log level. This can be used only once per
# node.
#
# Parameters:
#   namevar	- the lowest loglevel which should be sent to syslog
define collectd::syslog() {
	collectd::plugin {
		'syslog':
			lines => [ "LogLevel ${name}" ]
	}
}

