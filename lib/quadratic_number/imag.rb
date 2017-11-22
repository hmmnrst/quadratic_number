require_relative '../quadratic_number'

##
# Abstract class for <tt>Quadratic[d]</tt> (d < 0).
#
# Instances behave like those of <tt>Complex</tt>.
# See <tt>#to_c</tt> for details of the complex expression.
#
class Quadratic::Imag
	### Classification ###

	# defined by Numeric:
	# * integer? #=> false

	##
	# Returns false.
	#
	def real?
		false
	end

	### Basic arithmetic operations ###

	undef div, modulo, %, remainder, divmod
	undef floor, ceil, round, truncate

	### Comparisons ###

	undef <=>
	undef_method(*Comparable.public_instance_methods(false))

	##
	# @param [Object] other
	# @return [Boolean]
	#
	def ==(other)
		if other.kind_of?(Numeric)
			self.to_c - other == 0
		else
			other == self
		end
	end

	defined_methods = public_instance_methods
	undef positive? if defined_methods.include?(:positive?)
	undef negative? if defined_methods.include?(:negative?)

	undef step

	### Type conversions ###

	##
	# Returns an equivalent complex.
	# Its imaginary part is usually a <tt>Quadratic::Real</tt>.
	#
	# @return [Complex]
	#
	# @example
	#   Quadratic[-3].new(1, 2)      #=> (1+2√-3)
	#   Quadratic[-3].new(1, 2).to_c #=> (1+(0+2√3)*i)
	#   Quadratic[-1].new(3, 4)      #=> (3+4√-1)
	#   Quadratic[-1].new(3, 4).to_c #=> (3+4i)
	#
	def to_c
		d = self.class::D
		if d == -1
			Complex.rect(@a, @b)
		else
			rev_class = Quadratic[-d]
			Complex.rect(@a, rev_class.new(0, @b))
		end
	end

	##
	# @!method to_f
	# @return [Float]
	# @raise [RangeError] if its imaginary part is not zero.
	#

	##
	# @!method to_r
	# @return [Rational]
	# @raise [RangeError] if its imaginary part is not zero.
	#

	##
	# @!method rationalize(eps)
	# @param [Numeric] eps
	# @return [Rational]
	# @raise [RangeError] if its imaginary part is not zero.
	#

	##
	# @!method to_i
	# @return [Integer]
	# @raise [RangeError] if its imaginary part is not zero.
	#

	{
		:to_f => Float,
		:to_r => Rational,
		:rationalize => Rational,
		:to_i => Integer
	}.each do |sym,klass|
		define_method(sym) do |*args|
			if @b != 0
				raise RangeError,
				      "can't convert #{self} into #{klass}"
			end
			@a.send(sym, *args)
		end
	end

	### Complex operations ###

	alias conj qconj
	alias conjugate conj
	alias abs2 norm

	##
	# @!method rect
	# @return [[Integer/Rational, Quadratic[-d]]]
	#

	##
	# @!method real
	# @return [Integer/Rational]
	#

	##
	# @!method imag
	# @return [Quadratic[-d]]
	#

	##
	# @!method abs
	# @return [Real]
	#

	##
	# @!method arg
	# @return [Real]
	#

	##
	# @!method polar
	# @return [[Real, Real]]
	#

	[:rect, :real, :imag, :abs, :arg, :polar].each do |sym|
		define_method(sym) do
			to_c.send(sym)
		end
	end
	alias rectangular rect
	alias imaginary imag
	alias magnitude abs
	alias angle arg
	alias phase arg

	undef i
end
