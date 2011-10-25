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

ZeroVector=Vector[0,0,0].freeze

class MassPoint
	def initialize x,y,z,m
		@m=m
		@coords=Vector[x,y,z]
	end

	attr_reader :m, :coords
	alias mass m

	def moment center=ZeroVector
		(@coords - center) * @m
	end

	def inertia center=ZeroVector
		m=moment(center)
		m.inner_product(m)*Matrix.identity(3) -
			m*m.covector
	end
end

class MassPoints
	def initialize *points
		if error=points.find{|p| not p.instance_of?(MassPoint)}
			raise TypeError, 'Expected "%p" but "%p"' % [MassPoint, error.class]
		end
		@points=points
	end

	def center
		mass,moment=@points.inject([0,ZeroVector]) do |(mass,moment),point|
			[mass+point.mass, moment+point.moment]
		end
		moment*(1/mass)
	end

	def inertia
		center=center()
		@points.inject(Matrix.zero(3)) do |inertia, point|
			inertia + point.inertia(center)
		end
	end
end

doc = REXML::Document.new($stdin)

points = MassPoints.new *(doc.get_elements('molecule/atomArray/atom').collect do |atom|
	MassPoint.new(
		atom.attribute('x3').to_s.to_f,
		atom.attribute('y3').to_s.to_f,
		atom.attribute('z3').to_s.to_f,
		MassTable[atom.attribute('elementType').to_s]
	)
end)

$stderr.puts 'center of gravity = ' + (['%8.3f']*3).join(', ') % points.center.to_a

raw_inertia = points.inertia

$stderr.puts 'raw inertia:', MatrixFormat%raw_inertia.to_a.flatten

begin
	require 'gsl'
rescue LoadError
	exit 0
end

$stderr.puts 'diagonalized inertia:'
raw_inertia  = GSL::Matrix[*raw_inertia.to_a]
evals, evects = raw_inertia.eigen_symmv
GSL::Eigen::symmv_sort(evals,evects)
[evals.to_a, evects.transpose.to_a].transpose.each_with_index do |valvec,i|
	val,vec=valvec
	$stderr.puts 'I%d: %8.3f, axis(% 7f, % 7f, % 7f)' % [i+1, val, *vec]
end

center=GSL::Vector[*points.center.to_a]
doc.get_elements('molecule/atomArray/atom').each do |atom|
	v=GSL::Vector[*%w<x3 y3 z3>.collect{|l| atom.attribute(l).to_s.to_f}]
	v-=center
	v*=evects
	[%w<x3 y3 z3>, v.to_a].transpose.each do |l,v|
		atom.attributes[l]=v
	end
end
puts doc
