require 'cmled/doc/molecule/atom'

unless defined? Complex
	require 'complex'
end

module CMLed
	class Doc
		class Molecule
			def initialize element
				raise TypeError unless element.kind_of?(REXML::Element)
				@elem = element
				each_atom do |atom|
					atom.attributes.extend AtomAttributes
				end
			end

			def each_atom &block
				if block
					if @atoms
						@atoms.each &block
					else
						@elem.get_elements('atomArray/atom').each do |atom|
							block.call Atom.new(atom)
						end
					end
				else
					Enumerator.new(self,:each_atom)
				end
			end

			def atoms
				@atoms or @atoms = each_atom.to_a
			end

			def translate! axis, length
				coords =
					case axis
					when /\Ax\Z/i
						%w<y3 z3 x3>
					when /\Ay\Z/i
						%w<z3 x3 y3>
					when /\Az\Z/i
						%w<x3 y3 z3>
					when String
						raise ArgumentError, 'Unacceptable axis `%s\'!' % axis
					else
						return translate! axis.to_s, length
					end

				each_atom do |atom|
					x,y,z = coords.collect{|l| atom.attribute(l).to_s.to_f}
					z    += length
					[coords,[x,y,z]].transpose.each do |l,v|
						atom.attributes[l] = v
					end
				end
			end

			def rotate! axis, angle
				coords =
					case axis
					when /\Ax\Z/i
						%w<y3 z3 x3>
					when /\Ay\Z/i
						%w<z3 x3 y3>
					when /\Az\Z/i
						%w<x3 y3 z3>
					when String
						raise ArgumentError, 'Unacceptable axis `%s\'!' % axis
					else
						return rotate! axis.to_s, angle
					end

				rotator = Complex.polar(1, angle * 2 * Math::PI / 360)

				each_atom do |atom|
					x,y,z = coords.collect{|l| atom.attribute(l).to_s.to_f}
					c     = Complex(x,y) * rotator
					x,y   = c.real, c.imag
					[coords,[x,y,z]].transpose.each do |l,v|
						atom.attributes[l] = v
					end
				end
			end

			def mirror! plane

			end

			def filter! element
				each_atom do |atom|
					if atom.element == element
						atom.die!
					end
				end
			end

			def == other
				rexml_element == other.rexml_element
			end

			protected
			def rexml_element
				@elem
			end
		end
	end
end
