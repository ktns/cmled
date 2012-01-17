require 'rexml/document'
module CMLed
	class Doc
		def initialize *args
			@doc = REXML::Document.new(*args)
		end

		def write *args
			@doc.write *args
		end

		def molecules
			[@doc.get_elements('/molecule'),
				@doc.get_elements('/cml/molecule')].flatten.compact.collect do |mol|
				Molecule.new mol
			end
		end
	end
end

require 'cmled/doc/molecule'
