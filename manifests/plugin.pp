define collectd::plugin() {
	$content = join("\t\n", $lines)
	file {
		"/var/lib/puppet/modules/collectd/plugins/${name}.conf":
			content => "LoadPlugin ${name}\n<Plugin ${name}>\n\t${content}\n</Plugin>\n",
			mode => 0644, owner => root, group => 0,
			notify => Service['collectd'];
	}
}
