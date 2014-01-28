require 'cmled'
require 'cmled/masspoint'
require 'gsl'

module CMLed::Inertia
  def eigeninertia raw_inertia
    raw_inertia  = GSL::Matrix[*raw_inertia.to_a] unless GSL::Matrix === raw_inertia
    evals, evects = raw_inertia.eigen_symmv
    GSL::Eigen::symmv_sort(evals,evects)

    evects *= GSL::Matrix.diagonal(-1,1,1) if evects.det < 0
    evects  = Matrix[*evects.to_a]
    return [evals,evects]
  end

  def putseigeninertia evals,evects, io = $stderr
    [evals.to_a, evects.transpose.to_a].transpose.each_with_index do |valvec,i|
      val,vec=valvec
      io.puts 'I%d: %8.3f, axis(% 7f, % 7f, % 7f)' % [i+1, val, *vec]
    end
  end

  def alignmolecule center, evects, molecule, aligncenter = nil, alignevects = nil
    evects  = GSL::Matrix[*evects.to_a] unless GSL::Matrix === evects
    inverse = evects.invert
    inverse = Matrix[*inverse.to_a]
    center  = Vector[*center.to_a] unless Vector === center
    molecule.each_atom do |atom|
      atom.vector[:x]-=center
      atom.vector[:x]*=inverse
    end
    if alignevects
      alignevects = Matrix[*alignevects.to_a] unless Matrix === alignevects
      molecule.each_atom do |atom|
        atom.vector[:x]*=alignevects
      end
    end
    if aligncenter
      molecule.each_atom do |atom|
        atom.vector[:x]+=aligncenter
      end
    end
  end
end
