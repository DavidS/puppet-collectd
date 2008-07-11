define collectd::network($listen = '', $server = '', $ttl = '', $forward = 'false', $cache_flush = '1800') {
	collectd::plugin{
		'network':
			lines => [
				$listen ? { '' => '', default => "Listen ${listen}" },
				$server ? { '' => '', default => "Server ${server}" },
				$ttl ? { '' => '', default => "TimeToLive ${ttl}" },
				$forward ? { '' => '', default => "Forward ${forward}" },
				$cache_flush ? { '' => '', default => "CacheFlush ${cache_flush}" },
			]
		}
	}
}

