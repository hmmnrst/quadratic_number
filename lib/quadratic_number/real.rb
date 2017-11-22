require_relative '../quadratic_number'

##
# Abstract class for <tt>Quadratic[d]</tt> (d > 0).
#
class Quadratic::Real
	### Classification ###

	# defined by Numeric:
	# * integer? #=> false
	# * real?    #=> true

	### Basic arithmetic operations ###

	# defined by Numeric:
	# * div #=> (self / other).floor
	# * modulo, % #=> self - self.div(other) * other
	# * remainder
	# * divmod
	# * floor #=> to_f.floor
	# * ceil
	# * round
	# * truncate

	### Comparisons ###

	##
	# @param [Object] other
	# @return [+1/0/-1/nil]
	#
	def <=>(other)
		if other.kind_of?(Numeric)
			if other.real?
				(self - other).to_f <=> 0
			else
				n1, n2 = other.coerce(self)
				n1 <=> n2
			end
		else
			nil
		end
	end

	##
	# @param [Object] other
	# @return [Boolean]
	#
	def ==(other)
		if other.kind_of?(Numeric) && other.real?
			(self - other).to_f == 0
		else
			other == self
		end
	end

	### Type conversions ###

	# defined by Numeric:
	# * to_c #=> Complex.rect(self, 0)

	##
	# Returns a float.
	# Prevents cancellations of significant digits.
	#
	# @return [Float]
	#
	# @example
	#   -665857 + 470832 * Math.sqrt(2)        #=> -7.508788257837296e-07
	#   Quadratic[2].new(-665857, 470832).to_f #=> -7.509119826032946e-07
	#
	def to_f
		d = self.class::D
		if @a * @b < 0
			# Using #fdiv instead of #/
			# because Rational#/ returns Rational for a big Float divisor in ruby2.0
			(@a * @a - @b * @b * d).fdiv(@a - @b * Math.sqrt(d))
		else
			@a + @b * Math.sqrt(d)
		end
	end

	##
	# @!method to_r
	# @return [Rational]
	#

	##
	# @!method rationalize(eps)
	# @param [Numeric] eps
	# @return [Rational]
	#

	##
	# @!method to_i
	# @return [Integer]
	#

	[:to_r, :rationalize, :to_i].each do |sym|
		define_method(sym) do |*args|
			(@b == 0 ? @a : to_f).send(sym, *args)
		end
	end

	### Complex operations ###

	# defined by Numeric:
	# * conj, conjugate   #=> self
	# * abs2              #=> self * self
	# * rect, rectangular #=> [self, 0]
	# * real              #=> self
	# * imag, imaginary   #=> 0
	# * abs, magnitude    #=> self.negative? ? -self : self
	# * arg, angle, phase #=> self.to_f >= +0.0 ? 0 : Math::PI
	# * polar             #=> [abs, arg]
end
