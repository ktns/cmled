require File.expand_path(File.join(File.dirname(__FILE__), %w<..>, 'spec_helper'))

describe 'executable file `inertia.rb\'' do
	@@path = bin_path('inertia.rb')

	it 'should not raise error' do
		fixture_open 'benzene.cml' do |f|
			lambda do
				execute_file @@path, f
			end.should_not raise_error
		end
	end
end
