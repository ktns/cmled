module CMLed
	class Doc
		class Molecule
			def initialize element
				raise TypeError unless element.kind_of?(REXML::Element)
			end
		end
	end
end
