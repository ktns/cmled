module CMLed
	class Doc
		class Molecule
			class Atom
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
			end
		end
	end
end
