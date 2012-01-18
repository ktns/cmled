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
		end
	end
end
