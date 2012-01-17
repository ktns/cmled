module CMLed
	MassTable={
		'H' => 1.007947,
		'C' => 12.0107,
		'N' => 14.00672,
		'O' => 15.99943,
		'S' => 32.0655,
	}

	MassTable.default=0
	MassTable.freeze
end

require 'cmled/doc.rb'
