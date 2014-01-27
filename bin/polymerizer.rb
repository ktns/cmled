#! /usr/bin/env ruby

require 'rexml/document'
require 'matrix'

class Unit
	class Atom
		def initialize atom
			@x,@y,@z, @elem, @oldid = 
				*%w<x3 y3 z3 elementType id>.collect { |atr|
				atom.attributes[atr]
			}
			@x,@y,@z = [@x, @y, @z].collect(&:to_f)
			[@x, @y, @z, @elem, @id].each(&:freeze)
			self.freeze
		end
		attr_reader :elem, :oldid

		def to_v
			Vector[@x, @y, @z]
		end
	end

	class Bond
		def initialize bond, assoc
			@arefs = bond.attributes['atomRefs2'].split(' ')
			@atoms = @arefs.collect{|ref| assoc[ref]}
			@order = bond.attributes['order']
			@atoms.freeze
			self.freeze
		end

		attr_reader :atoms, :order
	end

	def initialize doc
		@id_assoc={}
		doc.get_elements('/molecule/atomArray/atom').each do |elem|
			atom=Atom.new(elem)
			@first||=atom
			unless %w<R Du Dummy>.include?(atom.elem)
				@id_assoc[atom.oldid]=atom
			else
				@dummy=atom
			end
		end
		@id_assoc.freeze
		@nextbonds, @bonds=doc.get_elements('/molecule/bondArray/bond').collect do |bond|
			Bond.new bond, @id_assoc
		end.partition{|bond| bond.atoms.include?(nil)}.collect(&:freeze)
		@offset=(@dummy.to_v-@first.to_v).freeze
		self.freeze
	end

	def atoms
		@id_assoc.values
	end

	attr_reader :bonds, :nextbonds, :offset, :first
end

class Polymer
	class Atom
		def initialize atom, offset, newid
			@atom=atom
			@coord=atom.to_v + offset
			@newid=newid
		end

		def to_elem
			elem=REXML::Element.new('atom')
			elem.add_attribute('id', @newid)
			elem.add_attribute('elementType', @atom.elem)
			[%w<x3 y3 z3>, @coord.to_a].transpose.each do |key, val|
				elem.add_attribute(key,val)
			end
			elem
		end

		attr_reader :newid
	end

	class Bond
		def initialize atoms, order=1
			raise ArgumentError if atoms.size!=2
			raise ArgumentError, '%p contains nil!' % [atoms] if atoms.include? nil
			@atoms=atoms.freeze
      @order=order
			freeze
		end

		def to_elem
			elem=REXML::Element.new('bond')
			elem.add_attribute('atomRefs2', @atoms.collect(&:newid).join(' '))
			elem.add_attribute('order', @order)
			elem
		end
	end

	def initialize unit, size
		@atoms=[]
		@bonds=[]
		@idnum=0
		prevbondsatoms=[]
		size.times do |i|
			assoc={}
			unit.atoms.each do |atom|
				@atoms << (assoc[atom]=Atom.new(atom,unit.offset*i,nextid))
			end
			first = assoc[unit.first]
			prevbondsatoms.each do |atoms|
				@bonds << Bond.new(atoms.collect{|bond|bond||first})
			end
			unit.bonds.each do |bond|
				atoms=bond.atoms.collect{|atom|assoc[atom]}
				@bonds << Bond.new(atoms, bond.order)
			end
			prevbondsatoms=unit.nextbonds.collect do |bond|
				bond.atoms.collect{|atom|assoc[atom]}
			end
		end
	end

	def nextid
		'a%d' % @idnum+=1
	end

	def to_cml
		doc=REXML::Document.new
		mol=REXML::Element.new('molecule',doc)
		aarray=REXML::Element.new('atomArray',mol)
		barray=REXML::Element.new('bondArray',mol)
		@atoms.each{|atom| aarray.add_element(atom.to_elem)}
		@bonds.each{|bond| barray.add_element(bond.to_elem)}
		doc
	end
end

unitdoc=REXML::Document.new($stdin)
unit=Unit.new(unitdoc)
polymer=Polymer.new(unit, ARGV.first.to_i)
polymerdoc=polymer.to_cml
polymerdoc.write($stdout,1)
