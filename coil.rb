#! /usr/bin/env ruby

require 'rexml/document'
require 'complex'

radius = ARGV[0].to_f
pitch    = ARGV[1].to_f
rotator = Math.exp(Complex::I*pitch * Math::PI / 180)

doc = REXML::Document.new($stdin)

doc.get_elements('molecule/atomArray/atom').collect do |atom|
	z,y,x = %w<x y z>.collect{|l|atom.attribute(l+'3').to_s.to_f}
	c = Complex.new(x,y) * rotator
	x,y = c.real, c.imag
	z += radius
	c = Complex.polar(z, y / radius)
	z,y = c.real, c.imag
	[[z,y,x],%w<x y z>].transpose.each do |v,l|
		atom.attributes[l+'3'] = '%.6f' % v
	end
end

puts doc
