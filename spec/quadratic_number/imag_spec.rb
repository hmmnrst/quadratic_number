require "spec_helper"

RSpec.describe Quadratic::Imag do
	it "has public instance methods like Complex" do
		q_methods = Quadratic[-3].public_instance_methods
		c_methods = Complex.public_instance_methods
		expect(c_methods - q_methods).to be_empty
		expect(q_methods - c_methods).to contain_exactly(
			:qconj, :quadratic_conjugate,
			:trace,
			:norm, :qabs2, :quadratic_abs2,
			:discriminant,
		)
	end

	describe ".new" do
		context "with a rational number" do
			it "returns (p/q)+0\u221ad" do
				a = Rational(2)
				num = Quadratic[-3].new(a)
				expect(num.instance_variable_get(:@a)).to eql a
				expect(num.instance_variable_get(:@b)).to eql 0
			end
		end

		context "with floating point numbers" do
			it do
				expect { Quadratic[-3].new(1.0, 2.0) }.to raise_error TypeError, "not a rational"
			end
		end
	end

	describe "#real?" do
		subject { Quadratic[-3].new(1, 2).real? }
		it { is_expected.to be false }
	end

	describe "#+" do
		it "returns a correct value" do
			me = Quadratic[-3].new(1, 2)
			[
				[me, Quadratic[-3].new(1, Rational(-1, 2)), Quadratic[-3].new(2, Rational(3, 2))],
				[me, Quadratic[-1].new(1, 2), Complex(2, Quadratic[3].new(2, 2))],
				[me, Rational(2, 3), Quadratic[-3].new(Rational(5, 3), 2)],
				[me, 0.0, Complex(1.0, Quadratic[3].new(0, 2))],
				[me, Complex::I, Complex(1, Quadratic[3].new(1, 2))],
			].each do |x,y,z|
				expect(x + y).to eql z
				expect(y + x).to eql z
			end
		end
	end

	describe "#-" do
		it "returns a correct value" do
			me = Quadratic[-3].new(1, 2)
			[
				[me, Quadratic[-3].new(1, Rational(-1, 2)), Quadratic[-3].new(0, Rational(5, 2))],
				[me, Quadratic[-1].new(1, 2), Complex(0, Quadratic[3].new(-2, 2))],
				[me, Rational(2, 3), Quadratic[-3].new(Rational(1, 3), 2)],
				[me, 0.0, Complex(1.0, Quadratic[3].new(0, 2))],
				[me, Complex::I, Complex(1, Quadratic[3].new(-1, 2))],
			].each do |x,y,z|
				expect(x - y).to eql z
				expect(y - x).to eql -z
			end
		end
	end

	describe "#*" do
		it "returns a correct value" do
			me = Quadratic[-3].new(1, 2)
			[
				[me, Quadratic[-3].new(1, Rational(-1, 2)), Quadratic[-3].new(Rational(4, 1), Rational(3, 2))],
				[me, Quadratic[-1].new(1, 2), Complex(Quadratic[3].new(1, -4), Quadratic[3].new(2, 2))],
				[me, Rational(2, 3), Quadratic[-3].new(Rational(2, 3), Rational(4, 3))],
				[me, 1.0, Complex(1.0, 3.4641016151377544)],
				[me, Complex::I, Complex(Quadratic[3].new(0, -2), Quadratic[3].new(1, 0))],
			].each do |x,y,z|
				expect(x * y).to eql z
				expect(y * x).to eql z
			end
		end
	end

	describe "#/" do
		it "returns a correct value" do
			me = Quadratic[-3].new(1, 2)
			[
				[me, Quadratic[-3].new(1, Rational(-1, 2)), Quadratic[-3].new(-8, 10) / 7],
				[me, Quadratic[-1].new(1, 2), Complex(Quadratic[3].new(1, 4), Quadratic[3].new(-2, 2)) / 5],
				[me, Rational(2, 3), Quadratic[-3].new(Rational(3, 2), Rational(3, 1))],
				[me, 1.0, Complex(1.quo(1.0), 3.4641016151377544)],   # 1.quo(1.0) == (1/1) in ruby2.0
				[me, Complex::I, Complex(Quadratic[3].new(0, 2), Quadratic[3].new(-1, 0)) / 1],
			].each do |x,y,z|
				expect(x / y).to eql z
			end
		end
	end

	describe "#**" do
		context "with an integer-like value" do
			it "returns a value as Quadratic" do
				omega = Quadratic[-3].new(-1, 1) / 2
				index = Quadratic[2].new(10, 0) / 1
				expect(omega ** index).to eql(omega)
			end
		end

		context "with a floating-point number" do
			it "returns a value as Complex" do
				omega = Quadratic[-3].new(-1, 1) / 2
				expect(omega ** 3.0).to eql(Complex(0.9999999999999997, 6.432490598706544e-16))
			end
		end
	end

	describe "#==" do
		subject { x == y }

		context "when x == y" do
			context "where y is Complex" do
				let(:x) { Quadratic[-3].new(-1, 1) / 2 }
				let(:y) { Complex("-0.5+0.8660254037844386i") }
				it { is_expected.to be true }
			end

			context "where y is Quadratic::Real" do
				let(:x) { Quadratic[-3].new(1) }
				let(:y) { Quadratic[5].new(1) }
				it { is_expected.to be true }
			end
		end

		context "when x != y" do
			let(:x) { Quadratic[-3].new(1, 2) }
			let(:y) { Quadratic[-2].new(1, 2) }
			it { is_expected.to be false }
		end

		context "when not comparable" do
			let(:x) { Quadratic[-2].new(1, 1) }
			let(:y) { "(1+1\u221a-2)" }
			it { is_expected.to be false }
		end
	end

	describe "#to_c" do
		context "when d == -1" do
			it "returns a Complex" do
				num = Quadratic[-1].new(3, 4)
				expect(num.to_c).to eql Complex(3, 4)
			end
		end

		context "when d < -1" do
			it "returns a Complex with Quadratic[d.abs]" do
				num = Quadratic[-3].new(3, 4)
				expect(num.to_c).to eql Complex(3, Quadratic[3].new(0, 4))
			end
		end
	end

	describe "#to_f" do
		context "when @b == 0" do
			it "returns a floating-point number" do
				num = Quadratic[-3].new(1, 0) / 2
				expect(num.to_f).to eql 0.5
			end
		end

		context "when @b != 0" do
			it do
				num = Quadratic[-3].new(1, 1)
				expect { num.to_f }.to raise_error RangeError, "can't convert #{num} into Float"
			end
		end
	end

	describe "#to_s" do
		it "returns a string" do
			val = -Quadratic[-3].new(1, 1) / 2
			expect(val.to_s).to eql "((-1/2)-(1/2)*\u221a-3)"
		end
	end
end
