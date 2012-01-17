require File.expand_path(File.join(File.dirname(__FILE__), %w<..>*2, 'spec_helper'))

describe CMLed::Doc::Molecule::AtomAttributes do
	before :each do
		@hash = {'id' => :id, 'x3' => :x3, 'elementType' => :elementType, 'y3' => :y3, 'z3' => :z3, 'hoge' => :hoge}
		@hash.extend CMLed::Doc::Molecule::AtomAttributes
	end

	describe '#to_a' do
		it 'should be ordered' do
			id, elementType, x3, y3, z3 = @hash.to_a
			id.should == ['id', :id]
			elementType.should == ['elementType', :elementType]
			x3.should == ['x3', :x3]
			y3.should == ['y3', :y3]
			z3.should == ['z3', :z3]
		end

		it 'should not drop any pair' do
			@hash.to_a.should include ['hoge', :hoge]
		end
	end
end
