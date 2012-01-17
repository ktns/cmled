module CMLed
	class Doc
		class Molecule
			def initalize element
				raise TypeError unless element.is_kind_of?(REXML::Element)
			end
		end
	end
end
