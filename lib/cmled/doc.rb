require 'rexml/document'
module CMLed
	class Doc
		def initialize *args
			@doc = REXML::Document.new(*args)
		end

		def write *args
			@doc.write *args
		end
	end
end
