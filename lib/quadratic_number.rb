require 'prime' # Prime.prime_division

class Quadratic < Numeric
	@@classes = {}

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

	def initialize(a, b = 0)
		unless [a, b].all? { |x| __rational__(x) }
			raise TypeError, "not a rational"
		end
		@a = a
		@b = b
	end
	private_class_method :new

	### Basic arithmetic operations ###

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

	def **(index)
		unless index.kind_of?(Numeric)
			num1, num2 = other.coerce(self)
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
		if index.kind_of?(Quadratic) && index.b == 0
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

	### Comparisons ###

	def eql?(other)
		if other.kind_of?(self.class)
			@a.eql?(other.a) && @b.eql?(other.b)
		else
			false
		end
	end

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

	def to_builtin
		real? ? to_f : to_c
	end
	protected :to_builtin

	def inspect
		'(' << __format__(:inspect) << ')'
	end
	alias to_s inspect

	### Utilities ###

	def denominator
		ad = @a.denominator
		bd = @b.denominator
		ad.lcm(bd)
	end

	def numerator
		an = @a.numerator
		ad = @a.denominator
		bn = @b.numerator
		bd = @b.denominator
		abd = ad.lcm(bd)
		self.class.new(an * (abd / ad), bn * (abd / bd))
	end

	### Extensions for Quadratic ###

	def qconj
		self.class.new(@a, -@b)
	end
	alias quadratic_conjugate qconj

	def trace
		# self + self.qconj
		@a * 2
	end

	def norm
		# self * self.qconj
		@a * @a - @b * @b * self.class::D
	end
	alias qabs2 norm
	alias quadratic_abs2 qabs2

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
