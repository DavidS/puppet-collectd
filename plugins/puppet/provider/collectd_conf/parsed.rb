require 'puppet/provider/parsedfile'

Puppet::Type.type(:collectd_conf).provide(:parsed,
	:parent => Puppet::Provider::ParsedFile,
	:default_target => "/etc/collectd/collectd.conf"
	) do

	text_line :comment, :match => %r{^#}

	text_line :blank, :match => %r{^\s*$}

	plugin = record_line :plugin_start, :fields => %w{name},
		:match => %r{^\s*<Plugin\s+(.*)\s*>\s*$}

	class << plugin
		def to_line(record)
			"<Plugin %s>\n%s\n</Plugin>" % [
				record[:name],
				record[:contents].join("\n")
			]
		end
	end

	record_line :plugin_end, :fields => [],
		:match => %r{^\s*</Plugin>\s*$}

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
		plugins = []

		plugin = nil
		contents = nil
		records.each { |record|

			case record[:record_type]
			when :plugin_start
				# start collecting lines within the <Plugin>
				plugin = record
				contents = []
			when :plugin_end
				# save the collected records
				plugin[:contents] = contents
				plugins << plugin
				plugin = nil
				contents = nil
			when :parsed
				if contents
					# collect the record
					contents << to_line(record)
				else
					# process this record
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
				end
			end
		}

		sorted_records.values + plugins
	end

	def self.instances
		prefetch()
		@records.find_all { |r| [:plugin_start, :parased].include?(r[:record_type]) }.collect { |r| new(r) }
	end

end
		
