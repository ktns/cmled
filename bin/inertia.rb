#! /usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(__FILE__), *%w<.. lib>)

require 'rexml/document'
require 'matrix'
require 'cmled'
require 'cmled/masspoint'

include CMLed

MatrixFormat = ((('% 11.3f '*3).rstrip+"\n")*3).freeze

ZeroVector=Vector[0,0,0].freeze

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
	require 'rubygems' and retry
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

evects*=GSL::Matrix.diagonal(-1,1,1) if evects.det < 0
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
