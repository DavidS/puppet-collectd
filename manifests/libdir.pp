# collectd/manifests/libdir.pp
# (C) Copyright: 2008, David Schmitt <david@dasz.at>

# private, a purged directory to store the various additional configs
define collectd::libdir() {
	file {
		"/var/lib/puppet/modules/${name}":
			source => "puppet:///collectd/empty", # recurse+purge needs empty directory as source
			checksum => mtime,
			ignore => '.ignore', # ignore the placeholder
			recurse => true, purge => true, force => true;
	}
}
