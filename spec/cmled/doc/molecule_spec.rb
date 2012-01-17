require File.expand_path(File.join(File.dirname(__FILE__), %w<..>*2, 'spec_helper'))

describe CMLed::Doc::Molecule::AtomAttributes do
	before :each do
		@doc = REXML::Document.new(<<EOF)
		<atom id="a1" elementType="C" x3="0.000000" y3="0.000000" z3="0.000000" hoge="hoge"/>
EOF
		@atom = @doc.root
		@attributes = @atom.attributes
		@attributes.extend CMLed::Doc::Molecule::AtomAttributes
		@array = Enumerator.new(@attributes,:each_attribute).to_a
	end

	describe '#each_attribute' do
		it 'should be ordered' do
			id, elementType, x3, y3, z3 = @array
			id.should == @attributes.get_attribute('id')
			elementType.should == @attributes.get_attribute('elementType')
			x3.should == @attributes.get_attribute('x3')
			y3.should == @attributes.get_attribute('y3')
			z3.should == @attributes.get_attribute('z3')
		end

		it 'should not drop any pair' do
			@array.any?{|attribute| attribute == @attributes.get_attribute('hoge')}.should be_true
		end
	end
end
