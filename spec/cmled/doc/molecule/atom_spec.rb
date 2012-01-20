require File.expand_path(File.join(File.dirname(__FILE__), %w<..>*3, 'spec_helper'))

class ::Vector
	alias abs r
end

describe CMLed::Doc::Molecule::AtomAttributes do
	before :each do
		@doc = REXML::Document.new(<<EOF)
		<atom id="a1" elementType="C" x3="1" y3="2" z3="3" hoge="hoge"/>
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

describe CMLed::Doc::Molecule::Atom do
	before :each do
		@doc = REXML::Document.new(<<EOF)
		<atom id="a1" elementType="C" x3="1" y3="2" z3="3" hoge="hoge"/>
EOF
		@atom = CMLed::Doc::Molecule::Atom.new(@doc.root)
	end

	describe '#complex' do
		shared_examples_for CMLed::Doc::Molecule::Atom::Complex do
			it 'should return a proper Complex' do
				axes.each do |axis|
					@atom.complex[axis].should be_within(1e-6).of(value)
				end
			end

			describe '=' do
				before :each do
					@random = Complex(rand(),rand())
				end

				it 'should change coordinates value' do
					@atom.complex[axes.first] = @random
					@atom.complex[axes.first].should be_within(1e-6).of(@random)
				end
			end
		end

		context 'with [x] axis' do
			it_behaves_like CMLed::Doc::Molecule::Atom::Complex do
				let(:axes){ ['x', 'X', :x , :X] }
				let(:value){ Complex(2,3) }
			end
		end

		context 'with [y] axis' do
			it_behaves_like CMLed::Doc::Molecule::Atom::Complex do
				let(:axes){ ['y', 'Y', :y , :Y] }
				let(:value){ Complex(3,1) }
			end
		end

		context 'with [z] axis' do
			it_behaves_like CMLed::Doc::Molecule::Atom::Complex do
				let(:axes){ ['z', 'Z', :z , :Z] }
				let(:value){ Complex(1,2) }
			end
		end
	end

	describe '#vector' do
		shared_examples_for CMLed::Doc::Molecule::Atom::Vector do
			it 'should return a proper Vector' do
				axes.each do |axis|
					@atom.vector[axis].should be_within(1e-6).of(value)
				end
			end

			describe '=' do
				before :each do
					@random = Vector[rand(),rand(),rand()]
				end

				it 'should change coordinates value' do
					@atom.vector[axes.first] = @random
					@atom.vector[axes.first].should be_within(1e-6).of(@random)
				end
			end

			describe '*' do
				before :all do
					@matrix = Matrix.I(4)
				end

				it 'should raise error if dimension unmatched' do
					proc do
						@matrix * @atom.vector[axes.first]
					end.should raise_error ExceptionForMatrix::ErrDimensionMismatch
				end
			end

			describe '*=' do
				before :each do
					@matrix = Matrix[*3.times.collect{3.times.collect{rand()}}]
				end

				it 'should multiply coordinates value' do
					@atom.vector[axes.first] *= @matrix
					@atom.vector[axes.first].should be_within(1e-6).of(@matrix * value)
				end
			end
		end

		context 'with [x] axis' do
			it_behaves_like CMLed::Doc::Molecule::Atom::Vector do
				let(:axes){ ['x', 'X', :x , :X] }
				let(:value){ Vector[1,2,3] }
			end
		end

		context 'with [y] axis' do
			it_behaves_like CMLed::Doc::Molecule::Atom::Vector do
				let(:axes){ ['y', 'Y', :y , :Y] }
				let(:value){ Vector[2,3,1] }
			end
		end

		context 'with [z] axis' do
			it_behaves_like CMLed::Doc::Molecule::Atom::Vector do
				let(:axes){ ['z', 'Z', :z , :Z] }
				let(:value){ Vector[3,1,2] }
			end
		end
	end
end
