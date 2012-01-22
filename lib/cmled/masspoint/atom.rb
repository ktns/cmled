require 'cmled/doc/molecule/atom'

module CMLed
	class Doc
		class Molecule
			class Atom
				def masspoint axis = :x
					MassPoint.new(MassTable[element], *vector[axis].to_a)
				end
			end
		end
	end
end
