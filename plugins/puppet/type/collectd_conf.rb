
Puppet::Type.newtype(:collectd_conf) do
	@doc = "Manages the basic statements collectd.conf file"

	ensurable

	newparam(:key) do
		desc "The configuration key"
		isnamevar
	end

	newproperty(:target) do
		desc "Which file to write to."
		defaultto "/etc/collectd/collectd.conf"
	end

	newproperty(:value, :array_matching => :all) do
		desc "The value to set. Use an array to set a key multiple times"

		def should_to_s(newvalue = @should)
			val_to_s(newvalue)
		end

		def is_to_s(currentvalue = @is)
			val_to_s(currentvalue)
		end
		
		# format an array of values for display
		def val_to_s(val) 
			if val
				unless val.is_a?(Array)
					val = [val]
				end
				val.join(",")
			else
				nil
			end
		end
	end
end

