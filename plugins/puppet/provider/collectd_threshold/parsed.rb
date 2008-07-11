require 'puppet/provider/parsedfile'

Puppet::Type.type(:collectd_threshold).provide(:parsed,
	:parent => Puppet::Provider::ParsedFile,
	:default_target => "/etc/collectd/thresholds.conf"
	) do

	LINE_MAP = {
		:warning_min => "WarningMin",
		:warning_max => "WarningMax",
		:failure_min => "FailureMin",
		:failure_max => "FailureMax",
		:invert => "Invert",
		:data_source => "DataSource",
		:instance => "Instance",
	}


	text_line :comment, :match => %r{^\s*#}

	text_line :blank, :match => %r{^\s*$}

	##  THRESHOLD  #################################################
	text_line :threshold_start, :fields => %w{name},
		:match => %r{^\s*<Threshold>\s*$}

	text_line :threshold_end, :match => %r{^\s*</Threshold>\s*$}

	##  HOST  ######################################################
	record_line :host_start, :fields => %w{name},
		:match => %r{^\s*<Host\s+"?([^\s"]*)"?\s*>\s*$}

	text_line :host_end, :match => %r{^\s*</Host>\s*$}

	##  PLUGIN  ####################################################
	record_line :plugin_start, :fields => %w{name},
		:match => %r{^\s*<Plugin\s+"?([^\s"]*)"?\s*>\s*$}

	text_line :plugin_end, :match => %r{^\s*</Plugin>\s*$}
	
	##  TYPE  ######################################################
	type = record_line :parsed,
		:fields => %w{name warning_min warning_max failure_min failure_max invert},
		:optional => %w{name warning_min warning_max failure_min failure_max invert},
		:match => %r{^\s*<Type\s+"?([^\s"]*)"?\s*>\s*$}

	class << type
		def to_line(record)
			lines = []

			path = Puppet::Type::Collectd_threshold::ProviderParsed.title_to_hash(record[:name])

			lines << "<Host \"%s\">" % path[:host] if path.has_key?(:host)
			lines << "<Plugin \"%s\">" % path[:plugin] if path.has_key?(:plugin)
			record[:instance] = path[:instance] if path.has_key?(:instance)
			lines << "<Type \"%s\">" % path[:type]
			record[:data_source] = path[:data_source] if path.has_key?(:data_source)

			LINE_MAP.keys.sort.each do |key|
				if record.has_key?(key) and record[key].to_s != ""
					lines << "%s \"%s\"" % [ LINE_MAP[key], record[key] ]
				end
			end
			lines << "</Type>"
			lines << "</Plugin>" if path.has_key?(:plugin)
			lines << "</Host>" if path.has_key?(:host)

			lines.flatten.join("\n")
		end
	end

	text_line :type_end, :match => %r{^\s*</Type>\s*$}

	##  ASSIGNMENT  ################################################

	assignment = record_line :assignment, :fields => %w{name value},
		:match => %r{^\s*(\S+)\s+"?([^"\s]+)"?\s*$}

	# collect the various nested scopes into a tree structure
	def self.prefetch_hook(records)
		records = collect_constraints(records)
		records = collect_flatten(records)
		records
	end

	def self.instances
		prefetch()
		@records.find_all { |r| [:plugin_start, :parased].include?(r[:record_type]) }.collect { |r| new(r) }
	end

	# Collect DataSource and Instance contstraints into their container
	# Since they can be scattered all over the place, this has to be done
	# before everything else
	def self.collect_constraints(records)
		parent_stack = []
		records.each do |record|
			case record[:record_type]
			when :comment, :blank
				# ignore
			when :threshold_start, :host_start, :plugin_start, :parsed
				parent_stack.push(record)
			when :threshold_end, :host_end, :plugin_end, :type_end
				parent_stack.pop
			when :assignment
				type = LINE_MAP.index(record[:name])

				unless type
					raise ArgumentError, "Invalid assignment type %s" % record[:name]
				end

				parent_stack.last[type] = record[:value]
				record[:collected] = true
			else
				puts record.inspect
				raise ArgumentError, "Unknown record type %s" % record[:type]
			end
		end
		records.reject do |record| record[:collected] end
	end

	def self.collect_flatten(records)
		parent_stack = []
		records.each do |record|
			case record[:record_type]
			when :comment, :blank, :threshold_start, :threshold_end
				# ignore
			when :host_start, :plugin_start
				parent_stack.push(record)
				record[:collected] = true
			when :host_end, :plugin_end, :type_end
				parent_stack.pop
				record[:collected] = true
			when :parsed
				parent_stack.push(record)
				record[:name] = stack_to_title(parent_stack)
			else
				puts record.inspect
				raise ArgumentError, "Unknown record type %s" % record[:type]
			end
		end
		records.reject do |record| record[:collected] end
	end
	
	def self.stack_to_title(stack)
		host = '*'
		plugin = '*'
		instance = '*'
		type = '*'
		data_source = '*'

		stack.reverse.each do |record|
			data_source = record[:data_source].to_s if record[:data_source].to_s != ""
			instance = record[:instance].to_s if record[:instance].to_s != ""

			case record[:record_type]
			when :parsed
				type = record[:name].to_s
			when :plugin_start
				plugin = record[:name].to_s
			when :host_start
				host = record[:name].to_s
			else
				puts record.inspect
				raise ArgumentError, "Unknown record type %s" % record[:type]
			end
		end
		plugin = "%s:%s" % [ plugin, instance ] if instance != '*'
		type = "%s:%s" % [ type, data_source ] if data_source != '*'
		"%s/%s/%s" % [ host, plugin, type ]
	end

	def self.title_to_hash(title)
		result = {}
		title =~ /^([^\/]+)\/([^\/:]+)(:[^\/]+)?\/([^\/:]+)(:[^\/]+)?/
		[:host, :plugin, :instance, :type, :data_source].zip([$1, $2, $3, $4, $5]).each do |pair|
			result[pair[0]] = pair[1]
		end
		[:host, :plugin].each do |selector|
			if result[selector] == '*'
				result.delete(selector)
			end
		end
		[:instance, :data_source].each do |sub_selector|
			if result[sub_selector].nil?
				result.delete(sub_selector)
			else
				result[sub_selector].gsub!(/^:/, '')
			end
		end
		result
	end
end
		
