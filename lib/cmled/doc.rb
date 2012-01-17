require 'rexml/document'
module CMLed
	class Doc
		def initialize *args
			@doc = REXML::Document.new(*args)
			raise ArgumentError if molecules.empty?
		end

		def to_s
			@doc.to_s
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
		
		def rotate *args
			dup.rotate! *args
		end

		def rotate! *args
			molecules.each do |mol|
				mol.rotate! *args
			end
			self
		end
	end
end

require 'cmled/doc/molecule'
