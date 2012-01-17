require File.expand_path(File.join(File.dirname(__FILE__), %w<..>, 'spec_helper'))

describe CMLed::Doc do
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
end
