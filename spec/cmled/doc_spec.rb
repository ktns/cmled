require File.expand_path(File.join(File.dirname(__FILE__), %w<..>, 'spec_helper'))
require 'stringio'

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
	end

	describe '#write' do
		it 'should produce identical string from source' do
			io1  = StringIO.new('','w')
			@doc.write(io1)
			io1.close
			io2  = StringIO.new(io1.string,'r')
			doc2 = CMLed::Doc.new(io2)
			io2.close
			io3  = StringIO.new('','w')
			doc2.write(io3)
			io3.close
			io2.string.should == io3.string
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
end
