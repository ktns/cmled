#!/usr/bin/ruby

require 'rexml/document'
require 'matrix'

MassTable={
	'H' => 1.007947,
	'C' => 12.0107,
	'N' => 14.00672,
	'O' => 15.99943,
	'S' => 32.0655,
}
MassTable.default=0
MassTable.freeze

MatrixFormat = ((('% 11.3f '*3).rstrip+"\n")*3).freeze

class MassPoint
	def initialize x,y,z,m
		@m=m
		@coords=Vector[x,y,z]
	end

	def inertia
		(
			@coords.inner_product(@coords)*Matrix.identity(3) -
			@coords*@coords.covector
		)*@m
	end
end

doc = REXML::Document.new($stdin)

raw_inertia = doc.get_elements('molecule/atomArray/atom').collect do |atom|
	MassPoint.new(
		atom.attribute('x3').to_s.to_f,
		atom.attribute('y3').to_s.to_f,
		atom.attribute('z3').to_s.to_f,
		MassTable[atom.attribute('elementType').to_s]
	)
end.inject(Matrix.zero(3)) do |inertia,point|
	inertia+point.inertia
end

puts 'raw inertia:', MatrixFormat%raw_inertia.to_a.flatten

puts 'diagonalized inertia:'
begin
	require 'gsl'

	raw_inertia  = GSL::Matrix[*raw_inertia.to_a]
	evals, evects = raw_inertia.eigen_symmv
	GSL::Eigen::symmv_sort(evals,evects)
	[evals.to_a, Enumerable::Enumerator.new(evects,:each_col).to_a].transpose.each_with_index do |valvec,i|
		val,vec=valvec
		puts 'I%d: %8.3f, axis(% 7f, % 7f, % 7f)' % [i+1, val, *vec]
	end
rescue LoadError
end
