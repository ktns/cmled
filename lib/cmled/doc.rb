require 'rexml/document'
require 'stringio'

unless defined? Enumerator
	Enumerator = Enumerable::Enumerator
end

module CMLed
	class Doc
		def initialize *args
			@doc = REXML::Document.new(*args)
			raise ArgumentError if molecules.empty?
		end

		def initialize_copy obj
			super
			@doc = REXML::Document.new(@doc.to_s)
		end

		def to_s
			@doc.to_s
		end

		def write *args
			@doc.write *args
		end

		def pretty *args
			io = StringIO.new('','w')
			write(io,*args)
			io.close
			io.string
		end

		def each_molecule &block
			if block
				proc=proc{|elem| block.call Molecule.new(elem)}
				@doc.get_elements('/molecule').each &proc
				@doc.get_elements('/cml/molecule').each &proc
			else
				Enumerator.new(self,:each_molecule)
			end
		end

		def molecules
			each_molecule.to_a
		end
		
		def rotate *args
			dup.rotate! *args
		end

		def rotate! *args
			each_molecule do |mol|
				mol.rotate! *args
			end
			self
		end
	end
end

require 'cmled/doc/molecule'
