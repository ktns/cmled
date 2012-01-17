require 'rexml/document'
module CMLed
	class Doc
		def initialize *args
			@doc = REXML::Document.new(*args)
		end
	end
end
