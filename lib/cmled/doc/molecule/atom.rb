module CMLed
	class Doc
		class Molecule
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

			class Atom
				def initialize elem
					raise TypeError unless elem.kind_of? REXML::Element
					@elem = elem
				end

				def self.labels axis
					case axis
					when /\Ax\Z/i
						%w<x3 y3 z3>
					when /\Ay\Z/i
						%w<y3 z3 x3>
					when /\Az\Z/i
						%w<z3 x3 y3>
					when String
						raise ArgumentError, 'Unacceptable axis `%s\'!' % axis
					else
						return labels axis.to_s
					end
				end

				class Complex
					def initialize parent
						raise TypeError unless parent.kind_of? Atom
						@parent = parent
					end

					def self.labels axis
						Atom.labels(axis)[1,2]
					end

					def [] axis
						Complex(*Complex.labels(axis).collect do |l|
							@parent.attributes[l].to_s.to_f
						end)
					end

					def []= axis, value
						[[value.real, value.imag], Complex.labels(axis)].transpose.each do |v,l|
							@parent.attributes[l]=v
						end
					end
				end

				def complex
					Complex.new(self)
				end

				def attributes
					@elem.attributes.extend AtomAttributes
				end
			end
		end
	end
end
