require File.expand_path(File.join(File.dirname(__FILE__), %w<..>, 'spec_helper'))

describe CMLed::MassPoints do
	before do
		fixture_open('benzene.cml') do |f|
			@doc = CMLed::Doc.new f
			@molecule = @doc.each_molecule.first
		end
	end

	context 'of fixture molecule' do |f|
		before do
			@masspoints = @molecule.masspoints
		end

		subject {@masspoints}

		its(:center) {should be_within(1e-4).of(Vector[0,0,0])}
	end
end
