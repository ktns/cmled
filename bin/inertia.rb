#! /usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(__FILE__), *%w<.. lib>)

require 'rexml/document'
require 'matrix'
require 'cmled'
require 'cmled/masspoint'

include CMLed

MatrixFormat = ((('% 11.3f '*3).rstrip+"\n")*3).freeze

doc = Doc.new($stdin)

molecule = doc.each_molecule.first
points = molecule.masspoints

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

evects *= GSL::Matrix.diagonal(-1,1,1) if evects.det < 0
evects  = Matrix[*evects.to_a]
center  = Vector[*points.center.to_a]
molecule.each_atom do |atom|
	atom.vector[:x]-=center
	atom.vector[:x]*=evects
end
puts doc
