unless defined? Complex
	require 'complex'
end

module CMLed
	class Doc
		class Molecule
			def initialize element
				raise TypeError unless element.kind_of?(REXML::Element)
				@elem = element
				each_atoms do |atom|
					atom.attributes.extend AtomAttributes
				end
			end

			module AtomAttributes
				def each_attribute &block
					if block
						order = %w<id elementType x3 y3 z3>
						stack = []
						super do |attribute|
							if attribute.name == order.first
								block.call attribute
								order.shift
								until order.empty?
									stack.size.times do
										stacked = stack.pop
										if stacked.name == order.first
											block.call stacked
											order.shift
											break false
										else
											stack.unshift stacked
										end
									end and break
								end
							else
								stack << attribute
							end
						end
						stack.sort_by{|attribute| attribute.name}.each &block
					else
						Enumerator.new(self, :each_attribute)
					end
				end
			end

			def each_atoms &block
				if block
					@elem.get_elements('atomArray/atom').each &block
				else
					Enumerator.new(self,each_atoms)
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

				@elem.get_elements('atomArray/atom').collect do |atom|
					x,y,z = coords.collect{|l| atom.attribute(l).to_s.to_f}
					c     = Complex(x,y) * rotator
					x,y   = c.real, c.imag
					[coords,[x,y,z]].transpose.each do |l,v|
						atom.attributes[l] = v
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
