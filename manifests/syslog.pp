
define collectd::syslog() {
	file {
		"/var/lib/puppet/modules/collectd/plugins/syslog.conf":
			content => "LoadPlugin syslog\n<Plugin syslog>\n\tLogLevel ${name}\n</Plugin>\n",
			mode => 0644, owner => root, group => 0,
			notify => Service['collectd'];
	}

}

