require File.expand_path(File.join(File.dirname(__FILE__), %w<..>, 'spec_helper'))

describe 'executable file `inertia.rb\'' do
	@@path = bin_path('inertia.rb')

	it 'should not raise error' do
		lambda do
			execute_file @@path
		end.should_not raise_error
	end
end
