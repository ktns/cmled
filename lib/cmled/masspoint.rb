require 'gsl'

module CMLed
	ZeroVector = Vector[0,0,0].freeze

	class MassPoint
		def initialize m,x,y,z
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

		def diagonalize_inertia
			inertia = GSL::Matrix[*inertia().to_a]
			evals, evects = inertia.eigen_symmv
			GSL::Eigen::symmv_sort(evals,evects)
			[evals, evects]
		end

		def principal_inertia
			diagonalize_inertia.first.to_a
		end

		def principal_axes
			_,evects = diagonalize_inertia
			Matrix[*evects.to_a]
		end
	end
end

require 'cmled/masspoint/molecule'
require 'cmled/masspoint/atom'
