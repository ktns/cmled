#! /usr/bin/env ruby

require 'rexml/document'
unless Kernel.const_defined? :Complex
	require 'complex'
end

radius      = ARGV[0].to_f
pitch       = ARGV[1].to_f
start_angle = (ARGV[2] || 0).to_f
$stderr.puts 'radius=%.5f, pitch=%.2f, start_angle=%.2f' % [radius,pitch,start_angle]
start_angle *= Math::PI / 180
rotator      = Complex.polar(1, pitch * Math::PI / 180)

doc = REXML::Document.new($stdin)

doc.get_elements('molecule/atomArray/atom').collect do |atom|
	z,y,x = %w<x y z>.collect{|l|atom.attribute(l+'3').to_s.to_f}
	c   = Complex(x,y) * rotator
	x,y = c.real, c.imag
	z  += radius
	c   = Complex.polar(z, y / radius + start_angle)
	z,y = c.real, c.imag
	[[z,y,x],%w<x y z>].transpose.each do |v,l|
		atom.attributes[l+'3'] = '%.6f' % v
	end
end

puts doc
