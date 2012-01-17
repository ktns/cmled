require File.expand_path(File.join(File.dirname(__FILE__), %w<..>, 'spec_helper'))

describe CMLed::Doc do
	describe '.new' do
		it 'should accept fixture/benzene.cml' do
			lambda do
				CMLed::Doc.new File.join(fixture_dir,'benzene.cml')
			end.should_not raise_error
		end
	end
end
