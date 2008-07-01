
define collectd::logfile($level, $timestamp = 'true') {
	file {
		"/var/lib/puppet/modules/collectd/plugins/logfile_${name}.conf":
			content => "LoadPlugin logfile\n<Plugin logfile>\n\tFile \"/var/log/collectd_${name}.log\"\n\tTimestamp ${timestamp}\n\tLogLevel ${loglevel}\n</Plugin>\n",
			mode => 0644, owner => root, group => 0,
			notify => Service['collectd'];
	}

}

