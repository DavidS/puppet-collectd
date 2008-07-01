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

	collectd::conf {
		'Include':
			value => [
				'/var/lib/puppet/modules/collectd/plugins/*.conf',
				'/var/lib/puppet/modules/collectd/thresholds/*.conf'
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

define collectd::conf($value, $ensure = present, $quote = '') {

	case $quote {
		'': {
			case $name {
				'LoadPlugin', 'TypesDB',
				'Server': {
					$quote_real = 'no'
				}
				'BaseDir', 'Include',
				'PIDFile', 'PluginDir',
				'Interval', 'ReadThreads',
				'Hostname', 'FQDNLookup': {
					$quote_real = 'yes'
				}
				default: {
					fail("Unknown collectd.conf directive: ${name}")
				}
			}
		}
		true, false, yes, no: {
			$quote_real = $quote
		}
	}

	case $quote_real {
		true, yes: {
			collectd_conf {
				$name:
					ensure => $ensure,
					notify => Service['collectd'],
					value => gsub($value, '^(.*)$', '"\1"')
			}
		}
		false, no: {
			collectd_conf {
				$name:
					ensure => $ensure,
					notify => Service['collectd'],
					value => $value
			}
		}
	}
}
