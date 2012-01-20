$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'cmled'
require 'cmled/masspoint'

def bin_dir
	File.expand_path(File.join(File.dirname(__FILE__), %w<.. bin>))
end

def bin_path *fn
	File.join(bin_dir,*fn)
end

def fixture_dir
	File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))
end

def fixture_path *fn
	File.join(fixture_dir,*fn)
end

def fixture_open *fn, &block
	File.open(fixture_path(*fn),'r',&block)
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end
