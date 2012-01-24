require 'rexml/document'
require 'stringio'

unless defined? Enumerator
	Enumerator = Enumerable::Enumerator
end

module CMLed
	class Doc
		def initialize *args
			if args.first.kind_of?(String) && File.readable?(args.first)
				File.open(args.shift, 'r') do |f|
					@doc = REXML::Document.new(f,*args)
				end
			else
				@doc = REXML::Document.new(*args)
			end
			raise ArgumentError if molecules.empty?
		end

		def initialize_copy obj
			super
			@doc = REXML::Document.new(@doc.to_s)
			@molecules = nil
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
				if @molecules
					@molecules.each &block
				else
					proc=proc{|elem| block.call Molecule.new(elem)}
					@doc.get_elements('/molecule').each &proc
					@doc.get_elements('/cml/molecule').each &proc
				end
			else
				Enumerator.new(self,:each_molecule)
			end
		end

		def molecules
			@molecules or @molecules = each_molecule.to_a
		end

		def translate *args
			dup.translate! *args
		end

		def translate! *args
			each_molecule do |mol|
				mol.translate! *args
			end
			self
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

		def filter *args, &block
			dup.filter! *args, &block
		end

		def filter! *args, &block
			each_molecule do |mol|
				mol.filter! *args, &block
			end
			self
		end

		def * operand
			dup.multiply! operand
		end

		def multiply! operand
			molecules.each do |mol|
				mol.atoms.each do |atom|
					atom.vector[:x] *= operand
				end
			end
			self
		end
	end
end

require 'cmled/doc/molecule'
