require 'prime' # Prime.prime_division

##
# Base class.
#
# Users must specify a square-free integer to get a concrete class (see class method +.[]+).
#
class Quadratic < Numeric
	@@classes = {}

	# @!parse class Real < self; end

	# @!parse class Imag < self; end

	##
	# Provides a concrete class.
	#
	# @param [Integer] d
	# @return [Class]
	# @raise [TypeError] if +d+ is not an integer.
	# @raise [RangeError] if +d+ is not square-free.
	#
	# @example
	#   Quadratic[2].ancestors.take(4)
	#   #=> [Quadratic[2], Quadratic::Real, Quadratic, Numeric]
	#   Quadratic[-1].ancestors.take(4)
	#   #=> [Quadratic[-1], Quadratic::Imag, Quadratic, Numeric]
	#
	def self.[](d)
		# return a memoized subclass if exists
		return @@classes[d] if @@classes[d]

		unless d.kind_of?(Integer)
			raise TypeError, 'not an integer'
		end

		if d == 0 || d == 1 ||
		   Prime.prime_division(d).any? { |p,k| k > 1 }
			raise RangeError, 'd must be square-free other than 0 or 1'
		end

		# memoize a new subclass and return it
		base = (d >= 0) ? Real : Imag
		@@classes[d] = Class.new(base) do
			# In this scope, `self` indicates a concrete subclass.
			self.const_set(:D, d)

			class << self
				def name
					"Quadratic[#{self::D}]"
				end
				alias to_s name
				alias inspect name

				public :new
			end
		end
	end

	Real = Class.new(self) { class << self; undef []; end }
	Imag = Class.new(self) { class << self; undef []; end }

	attr_reader :a, :b
	protected   :a, :b

	##
	# Returns <tt>(a+b√d)</tt>.
	#
	# @example
	#   phi   = Quadratic[5].new(1, 1) / 2     #=> ((1/2)+(1/2)*√5)
	#   omega = Quadratic[-3].new(-1, 1) / 2   #=> ((-1/2)+(1/2)*√-3)
	#
	def initialize(a, b = 0)
		unless [a, b].all? { |x| __rational__(x) }
			raise TypeError, "not a rational"
		end
		@a = a
		@b = b
	end
	private_class_method :new

	### Basic arithmetic operations ###

	##
	# Performs type conversion.
	#
	# @param [Numeric] other
	# @return [[Numeric, Numeric]] +other+ and +self+
	# @raise [TypeError]
	#
	def coerce(other)
		my_class = self.class
		if other.kind_of?(my_class)
			# my_class
			[other, self]
		elsif __rational__(other)
			# Integer and Rational
			[my_class.new(other, 0), self]
		elsif other.kind_of?(Quadratic)
			# Quadratic::Real and Quadratic::Imag
			if self.real? && other.real?
				[other.to_f, self.to_f]
			else
				[other.to_c, self.to_c]
			end
		elsif __real__(other)
			# Float and BigDecimal
			[other, self.to_builtin]
		elsif __complex__(other)
			# Complex
			[other, self.to_c]
		else
			# others
			raise TypeError,
			      "#{other.class} can't be coerced into #{self.class}"
		end
	end

	##
	# Performs addition.
	#
	# @param [Numeric] other
	# @return [Quadratic[d]]
	#
	def +(other)
		my_class = self.class
		if other.kind_of?(my_class)
			my_class.new(@a + other.a, @b + other.b)
		elsif __rational__(other)
			my_class.new(@a + other, @b)
		else
			__coerce_exec__(:+, other)
		end
	end

	##
	# Performs subtraction.
	#
	# @param [Numeric] other
	# @return [Quadratic[d]]
	#
	def -(other)
		my_class = self.class
		if other.kind_of?(my_class)
			my_class.new(@a - other.a, @b - other.b)
		elsif __rational__(other)
			my_class.new(@a - other, @b)
		else
			__coerce_exec__(:-, other)
		end
	end

	##
	# Performs multiplication.
	#
	# @param [Numeric] other
	# @return [Quadratic[d]]
	#
	def *(other)
		my_class = self.class
		if other.kind_of?(my_class)
			_a = other.a
			_b = other.b
			my_class.new(@a * _a + @b * _b * my_class::D, @a * _b + @b * _a)
		elsif __rational__(other)
			my_class.new(@a * other, @b * other)
		else
			__coerce_exec__(:*, other)
		end
	end

	##
	# Performs division.
	#
	# @param [Numeric] other
	# @return [Quadratic[d]]
	#
	def quo(other)
		my_class = self.class
		if other.kind_of?(my_class)
			_a = other.a
			_b = other.b
			d = _a * _a - _b * _b * my_class::D
			self * my_class.new(_a.quo(d), -_b.quo(d))
		elsif __rational__(other)
			my_class.new(@a.quo(other), @b.quo(other))
		else
			__coerce_exec__(:quo, other)
		end
	end
	alias / quo

	##
	# Performs division.
	#
	# @param [Numeric] other
	# @return [Float/Complex]
	#
	def fdiv(other)
		if other.kind_of?(Quadratic)
			self.to_builtin.fdiv(other.to_builtin)
		elsif other.kind_of?(Numeric)
			self.to_builtin.fdiv(other)
		else
			n1, n2 = other.coerce(self)
			n1.fdiv(other)
		end
	end

	##
	# Performs exponentiation.
	#
	# @param [Numeric] index
	# @return [Quadratic[d]/Float/Complex]
	#
	def **(index)
		unless index.kind_of?(Numeric)
			num1, num2 = index.coerce(self)
			return num1 ** num2
		end

		# return 1 if index is exactly zero
		begin
			1 / index
		rescue ZeroDivisionError
			return self.class.new(1, 0)
		end

		# complex -> real
		begin
			index.to_f
		rescue
		else
			index = index.real
		end

		# quadratic -> rational or integer / float or complex
		if index.kind_of?(Quadratic)
			if index.b == 0
				index = index.a
			else
				index = index.to_builtin
			end
		end

		# rational -> integer
		if index.kind_of?(Rational) && index.denominator == 1
			index = index.numerator
		end

		if index.integer?
			# binary method
			x = (index >= 0) ? self : 1 / self
			n = index.abs

			z = self.class.new(1, 0)
			while true
				n, i = n.divmod(2)
				z *= x if i == 1
				return z if n == 0
				x *= x
			end
		else
			return self.to_builtin ** index
		end
	end

	##
	# Returns negation of the value.
	#
	# @return [Quadratic[d]]
	#
	def -@
		self.class.new(-@a, -@b)
	end

	### Comparisons ###

	##
	# Returns true if the two numbers are equal including their types.
	#
	# @param [Object] other
	# @return [Boolean]
	#
	def eql?(other)
		if other.kind_of?(self.class)
			@a.eql?(other.a) && @b.eql?(other.b)
		else
			false
		end
	end

	##
	# Returns a hash value.
	#
	# @return [Integer]
	#
	def hash
		[@a, @b, self.class::D].hash
	end

	# defined by Numeric:
	# * zero?     #=> self == 0
	# * nonzero?  #=> zero? ? nil : self
	# * positive? #=> self > 0
	# * negative? #=> self < 0
	# * finite?   #=> true
	# * infinite? #=> nil

	### Type conversions ###

	##
	# Convert to a bilt-in class' object.
	#
	# @return [Float/Complex]
	#
	def to_builtin
		real? ? to_f : to_c
	end
	protected :to_builtin

	##
	# Returns a string.
	#
	# @return [String]
	#
	def inspect
		'(' << __format__(:inspect) << ')'
	end
	alias to_s inspect

	### Utilities ###

	##
	# Returns its denominator.
	#
	# @return [Integer]
	#
	def denominator
		ad = @a.denominator
		bd = @b.denominator
		ad.lcm(bd)
	end

	##
	# Returns its numerator.
	#
	# @return [Quadratic[d]]
	#
	def numerator
		an = @a.numerator
		ad = @a.denominator
		bn = @b.numerator
		bd = @b.denominator
		abd = ad.lcm(bd)
		self.class.new(an * (abd / ad), bn * (abd / bd))
	end

	### Extensions for Quadratic ###

	##
	# Returns its quadratic conjugate.
	#
	# @return [Quadratic[d]]
	#
	def qconj
		self.class.new(@a, -@b)
	end
	alias quadratic_conjugate qconj

	##
	# Returns its trace.
	#
	# @return [Integer/Rational]
	#
	def trace
		# self + self.qconj
		@a * 2
	end

	##
	# Returns its norm.
	#
	# @return [Integer/Rational]
	#
	def norm
		# self * self.qconj
		@a * @a - @b * @b * self.class::D
	end
	alias qabs2 norm
	alias quadratic_abs2 qabs2

	##
	# Returns its discriminant.
	#
	# @return [Integer/Rational]
	#
	def discriminant
		# trace ** 2 - 4 * norm
		@b * @b * (self.class::D * 4)
	end

	private

	# Integer and Rational
	def __rational__(x)
		x.kind_of?(Integer) || x.kind_of?(Rational)
	end

	# Integer, Rational,
	# Quadratic::Real, Float, and BigDecimal
	def __real__(x)
		x.kind_of?(Numeric) && x.real?
	end

	# Complex and Quadratic::Imag
	def __complex__(x)
		x.kind_of?(Complex) || x.kind_of?(Imag)
	end

	def __coerce_exec__(op, other)
		if other.kind_of?(Quadratic)
			if self.real? && other.real?
				n1 = self.to_f
				n2 = other.to_f
			else
				n1 = self.to_c
				n2 = other.to_c
			end
		elsif __real__(other)
			n1 = self.to_builtin
			n2 = other
		elsif __complex__(other)
			n1 = self.to_c
			n2 = other
		else
			n1, n2 = other.coerce(self)
		end

		n1.send(op, n2)
	end

	def __format__(sym)
		str = ''
		str << @a.send(sym)
		if @b >= 0
			str << '+' << @b.send(sym)
		else
			str << '-' << (-@b).send(sym)
		end
		str << "*" if /\D\z/ === str
		str << "\u221a#{self.class::D}"
	end
end

require_relative 'quadratic_number/real'
require_relative 'quadratic_number/imag'
