require 'matrix'
require 'cmled/doc/molecule/atom/complex'
require 'cmled/doc/molecule/atom/vector'

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

			module AtomID
				include Comparable

				def self.extended str
					unless str.instance_of? String
						raise TypeError, 'Expected String, but %p!' % str
					end
					unless str =~ /\Aa(\d+)\Z/
						raise ArgumentError, 'Invalid string for AtomID! (%s)' % str
					end
				end

				def <=> other
					raise TypeError, 'Expected AtomID, but %p!' % other unless other.kind_of? AtomID
					:<=>.to_proc.call(*[self,other].collect{|str| str.scan(/\d+/)}.flatten.collect(&:to_i))
				end

				protected
				attr_reader :num
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

				def complex
					Complex.new(self)
				end

				def vector
					Vector.new(self)
				end

				def vector= value
					Vector.new(self)[:x]=value
				end

				def attributes
					@elem.attributes.extend AtomAttributes
				end

				def attribute key
					@elem.attribute(key)
				end

				def element
					@elem.attributes['elementType']
				end

				def die!
					@elem.parent.delete @elem
				end
			end
		end
	end
end
