# collectd/manifests/init.pp - statistics collection and monitoring daemon
# (C) Copyright: 2008, David Schmitt <david@dasz.at>

class collectd {

	modules_dir { ['collectd', 'collectd/plugins', 'collectd/thresholds' ]: }

	package {
		'collectd':
			ensure => installed;
	}

	service {
		'collectd':
			ensure => running,
			enable => true,
			hasrestart => true,
			pattern => collectd,
			require => Package['collectd'];
	}

	config_file {
		'/etc/collectd/collectd.conf':
			ensure => present,
			require => Package['collectd'],
			notify => Service['collectd'];
	}

	collectd_conf {
		'Include':
			value => [
				'"/var/lib/puppet/modules/collectd/plugins/*.conf"',
				'"/var/lib/puppet/modules/collectd/thresholds/*.conf"'
			];
	}

	# add customisations for distributions here
	case $operatingsystem {
		'debian': {
			case $debianversion {
				'etch': {
				}
			}
		}
		default: {
			# no changes needed
		}
	}
}
