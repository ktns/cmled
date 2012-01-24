require File.expand_path(File.join(File.dirname(__FILE__), %w<..>, 'spec_helper'))

describe CMLed::Doc do
	before do
		fixture_open('benzene.cml') do |f|
			@doc = CMLed::Doc.new f
		end
	end

	describe '.new' do
		it 'should accept fixture/benzene.cml' do
			lambda do
				fixture_open('benzene.cml') do |f|
					CMLed::Doc.new f
				end
			end.should_not raise_error
		end

		it 'should not accept bad string' do
			lambda do
				CMLed::Doc.new 'hoge'
			end.should raise_error
		end

		it 'should accept path to fixture/benzene.cml' do
			lambda do
				CMLed::Doc.new fixture_path('benzene.cml')
			end.should_not raise_error
		end
	end

	describe '#pretty' do
		it 'should reproduce identical string' do
			pretty = @doc.pretty
			CMLed::Doc.new(pretty).pretty.should == pretty
		end
	end

	describe '#each_molecule' do
		context 'without block' do
			before do
				@enumerator = @doc.each_molecule
			end

			it 'should return Enumerator if block is not given' do
				@enumerator.should be_instance_of Enumerator
			end

			it 'should have proper count of enum' do
				@enumerator.count.should == 1
			end

			it 'should enumerate same molecules as with block' do
				a=@enumerator.to_a
				@doc.each_molecule do |m|
					a.delete(m).should_not be_nil
				end
				a.should be_empty
			end
		end

		it 'should enumerate CMLed::DocDoc::Molecule' do
			@doc.each_molecule do |m|
				m.should be_instance_of CMLed::Doc::Molecule
			end
		end
	end

	describe '#molecules' do
		it 'should return an array of CMLed::Doc::Molecule' do
			@doc.molecules.each do |mol|
				mol.should be_kind_of CMLed::Doc::Molecule
			end
		end

		it 'should have proper size' do
			@doc.molecules.size.should == 1
		end
	end

	describe '#translate' do
		it 'should return translatedcml' do
			@translateddoc = IO.popen("#{bin_path('translatecml')} z 1 < #{fixture_path('benzene.cml')} 2>/dev/null", 'r') do |io|
				CMLed::Doc.new(io)
			end
			@translatedstr = @translateddoc.pretty
			@doc.translate(:z,1).pretty.should == @translatedstr
		end

		it 'should not change original document' do
			str = @doc.to_s
			@doc.translate(:z,2)
			@doc.to_s.should == str
		end
	end

	describe '#rotate' do
		it 'should return rotatedcml' do
			@rotateddoc = IO.popen("#{bin_path('rotatecml')} x 90 < #{fixture_path('benzene.cml')} 2>/dev/null", 'r') do |io|
				CMLed::Doc.new(io)
			end
			@rotatedstr = @rotateddoc.pretty
			@doc.rotate(:x,90).pretty.should == @rotatedstr
		end

		it 'should not change original document' do
			str = @doc.to_s
			@doc.rotate(:x,180)
			@doc.to_s.should == str
		end
	end

	describe '#filter' do
		it 'should return filtered cml' do
			@doc.filter('H').each_molecule do |mol|
				mol.each_atom do |atom|
					atom.element.should_not == 'H'
				end
			end
		end

		it 'should not change original document' do
			str = @doc.to_s
			@doc.filter('H')
			@doc.to_s.should == str
		end
	end
end
