Exec { path => '/sbin:/bin:/usr/sbin:/usr/bin' }

filebucket { 'server': }

import "common"
import "collectd"

include collectd

collectd_conf {
	'BaseDir': value => 'foo';
	'Server': value => [ '"foo" 1000', '"foo2" 2000' ];
}
