module CMLed
	class Doc
		class Molecule
			class Atom
				class Vector
					module CoVector
						def * operand
							begin
								super
							rescue ExceptionForMatrix::ErrDimensionMismatch => e
								begin
									operand * self
								rescue ExceptionForMatrix::ErrDimensionMismatch
									raise e
								end
							end
						end
					end

					def initialize parent
						raise TypeError unless parent.kind_of? Atom
						@parent = parent
					end

					def [] axis = :x
						::Vector[*Atom.labels(axis).collect do |l|
							@parent.attributes[l].to_s.to_f
						end].extend CoVector
					end

					def []= axis, value
						[Atom.labels(axis),value.to_a].transpose.each do |l,v|
							@parent.attributes[l] = v
						end
					end
				end
			end
		end
	end
end
