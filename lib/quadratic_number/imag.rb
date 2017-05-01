require_relative '../quadratic_number'

class Quadratic::Imag # < Quadratic < Numeric
	### Classification ###

	# defined by Numeric:
	# * integer? #=> false

	def real?
		false
	end

	### Basic arithmetic operations ###

	undef div, modulo, %, remainder, divmod
	undef floor, ceil, round, truncate

	### Comparisons ###

	undef <=>
	undef_method(*Comparable.public_instance_methods(false))
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

	def to_c
		d = self.class::D
		if d == -1
			Complex.rect(@a, @b)
		else
			rev_class = Quadratic[-d]
			Complex.rect(@a, rev_class.new(0, @b))
		end
	end

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
