require 'puppet/provider/parsedfile'

Puppet::Type.type(:collectd_conf).provide(:parsed,
	:parent => Puppet::Provider::ParsedFile,
	:default_target => "/etc/collectd/collectd.conf"
	) do

	text_line :comment, :match => %r{^#}

	text_line :blank, :match => %r{^\s*$}

	config = record_line :parsed, :fields => %w{name value},
		:match => %r{^\s*(\S+)\s+(.*)$}

	class << config
		def to_line(record)
			values = [ record[:value] ]
			if record[:value].is_a? Array 
				values = record[:value]
			end
			values.collect do |v| "%s %s" % [ record[:name], v ] end.join("\n")
		end
	end

	# coalesce configuration directives with multiple values
	def self.prefetch_hook(records)

		sorted_records = {}

		records.each { |record|

			value = nil
			if record[:value]
				unless record[:value].is_a?(Array) 
					value = [ record[:value] ]
				else
					value = record[:value]
				end
			end

			real_record = nil
			if sorted_records[record[:name]]
				real_record = sorted_records[record[:name]]
				value += real_record[:value]
			else
				real_record = record
			end

			real_record[:value] = value
			sorted_records[record[:name]] = real_record
		}

		sorted_records.values.collect { |record|
			record
		}
	end
end
		
