# generic join call
# example:
# $lines = ["a", "b"]
# $content = join("\n", $lines)
# $content == "a\nb"
module Puppet::Parser::Functions
	newfunction(:join, :type => :rvalue) do |args|
		args[1].join(args[0]) rescue "\n"
	end
end

