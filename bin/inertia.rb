#! /usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(__FILE__), *%w<.. lib>)

require 'rexml/document'
require 'matrix'
require 'cmled'
require 'cmled/inertia'
require 'optparse'

include CMLed

opt = OptionParser.new
inertiafile,inertiadoc,inertiamol = [nil]*3
opt.on('-i FILE', 'read inertia from FILE instead of input molecule') do |v|
  inertiafile = v
  inertiadoc  = Doc.new(v)
  inertiamol  = inertiadoc.each_molecule.first
end
alignfile,aligndoc,alignmol = [nil]*3
opt.on('-a FILE', 'align input molecule to inertial axis read from FILE') do |v|
  alignfile = v
  aligndoc  = Doc.new(v)
  alignmol  = aligndoc.each_molecule.first
end
opt.parse!(ARGV)

MatrixFormat = ((('% 11.3f '*3).rstrip+"\n")*3).freeze

doc = Doc.new(ARGF)

molecule = doc.each_molecule.first
points = (inertiamol or molecule).masspoints

$stderr.puts 'center of gravity = ' + (['%8.3f']*3).join(', ') % points.center.to_a

raw_inertia = points.inertia

$stderr.puts 'raw inertia:', MatrixFormat%raw_inertia.to_a.flatten

center  = Vector[*points.center.to_a]

$stderr.puts 'diagonalized inertia:'
include CMLed::Inertia
evals, evects = eigeninertia raw_inertia
putseigeninertia evals, evects, $stderr

aligncenter, alignevects = [nil]*2
if alignmol
  alignpoints  = alignmol.masspoints
  aligncenter  = alignpoints.center
  aligninertia = alignpoints.inertia
  alignevals, alignevects = eigeninertia aligninertia
  $stderr.puts 'aligns to center of gravity = ' + (['%8.3f']*3).join(', ') % aligncenter.to_a
  $stderr.puts 'aligns to following inertial frame:'
  putseigeninertia alignevals, alignevects
end

alignmolecule center, evects, molecule, aligncenter, alignevects
puts doc
