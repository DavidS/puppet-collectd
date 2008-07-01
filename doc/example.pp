Exec { path => '/sbin:/bin:/usr/sbin:/usr/bin' }

filebucket { 'server': }

import "common"
import "collectd"

include collectd

resources { collectd_conf: purge => true; }

collectd_conf {
	'FQDNLookup':
		notify => Service['collectd'],
		value => 'true';
	'Server':
		notify => Service['collectd'],
		value => [ '"foo" 1002', '"foo3" 2000' ];
	'LoadPlugin':
		notify => Service['collectd'],
		value => [ 'syslog', 'network', 'cpu' ];
}

collectd::syslog { 'debug': }
collectd::logfile {
	'debug': level => debug;
	'error': level => err;
}

