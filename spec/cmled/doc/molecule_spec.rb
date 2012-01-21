require File.expand_path(File.join(File.dirname(__FILE__), %w<..>*2, 'spec_helper'))

describe CMLed::Doc::Molecule do
	before do
		fixture_open('benzene.cml') do |f|
			@doc = CMLed::Doc.new(f)
		end
		@molecule = @doc.each_molecule.first
	end

	describe '#each_atom' do
		context 'without block' do
			subject{@molecule.each_atom}

			it {should be_kind_of Enumerator}
		end

		it 'should enumerate CMLed::Doc::Molecule::Atom' do
			@molecule.each_atom do |atom|
				atom.should be_kind_of CMLed::Doc::Molecule::Atom
			end
		end
	end
end
