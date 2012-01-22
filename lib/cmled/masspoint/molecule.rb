require 'cmled/doc/molecule/atom'

module CMLed
	class Doc
		class Molecule
			def masspoints
				MassPoints.new *(each_atom.collect{|atom|atom.masspoint})
			end
		end
	end
end
