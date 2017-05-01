require "spec_helper"

RSpec.describe Quadratic::Real do
	it "has public instance methods like Rational" do
		q_methods = Quadratic[5].public_instance_methods
		r_methods = Rational.public_instance_methods
		expect(r_methods - q_methods).to be_empty
		expect(q_methods - r_methods).to contain_exactly(
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
				num = Quadratic[5].new(a)
				expect(num.instance_variable_get(:@a)).to eql a
				expect(num.instance_variable_get(:@b)).to eql 0
			end
		end

		context "with floating point numbers" do
			it do
				expect { Quadratic[5].new(1.0, 2.0) }.to raise_error TypeError, "not a rational"
			end
		end
	end

	describe "#real?" do
		subject { Quadratic[5].new(1, 2).real? }
		it { is_expected.to be true }
	end

	describe "#+" do
		it "returns a correct value" do
			me = Quadratic[5].new(1, 2)
			[
				[me, Quadratic[5].new(1, Rational(-1, 2)), Quadratic[5].new(2, Rational(3, 2))],
				[me, Quadratic[3].new(1, 2), 5.47213595499958 + 4.464101615137754],
				[me, Rational(2, 3), Quadratic[5].new(Rational(5, 3), 2)],
				[me, 0.0, 5.47213595499958],
				[me, Complex::I, Complex(me, 1)],
			].each do |x,y,z|
				expect(x + y).to eql z
				expect(y + x).to eql z
			end
		end
	end

	describe "#-" do
		it "returns a correct value" do
			me = Quadratic[5].new(1, 2)
			[
				[me, Quadratic[5].new(1, Rational(-1, 2)), Quadratic[5].new(0, Rational(5, 2))],
				[me, Quadratic[3].new(1, 2), 5.47213595499958 - 4.464101615137754],
				[me, Rational(2, 3), Quadratic[5].new(Rational(1, 3), 2)],
				[me, 0.0, 5.47213595499958],
				[me, Complex::I, Complex(me, -1)],
			].each do |x,y,z|
				expect(x - y).to eql z
				expect(y - x).to eql -z
			end
		end
	end

	describe "#*" do
		it "returns a correct value" do
			me = Quadratic[5].new(1, 2)
			[
				[me, Quadratic[5].new(1, Rational(-1, 2)), Quadratic[5].new(Rational(-4, 1), Rational(3, 2))],
				[me, Quadratic[3].new(1, 2), 5.47213595499958 * 4.464101615137754],
				[me, Rational(2, 3), Quadratic[5].new(Rational(2, 3), Rational(4, 3))],
				[me, 1.0, 5.47213595499958],
				[me, Complex::I, Complex(Quadratic[5].new(0, 0), me)],
			].each do |x,y,z|
				expect(x * y).to eql z
				expect(y * x).to eql z
			end
		end
	end

	describe "#/" do
		it "returns a correct value" do
			me = Quadratic[5].new(1, 2)
			[
				[me, Quadratic[5].new(1, Rational(-1, 2)), Quadratic[5].new(-24, -10) / 1],
				[me, Quadratic[3].new(1, 2), 5.47213595499958 / 4.464101615137754],
				[me, Rational(2, 3), Quadratic[5].new(Rational(3, 2), Rational(3, 1))],
				[me, 1.0, 5.47213595499958],
				[me, Complex::I, Complex(Quadratic[5].new(0, 0) / 1, -me / 1)],
			].each do |x,y,z|
				expect(x / y).to eql z
			end
		end
	end

	describe "#**" do
		context "with an integer-like value" do
			it "returns a value as Quadratic" do
				phi = Quadratic[5].new(1, 1) / 2
				index = Quadratic[2].new(-3, 0) / 1
				expect(phi ** index).to eql(phi * 2 - 3)
			end
		end

		context "with a floating-point number" do
			it "returns a value as Float" do
				phi = Quadratic[5].new(1, 1) / 2
				expect(phi ** -3.0).to eql(phi.to_f ** -3)
			end
		end
	end

	describe "#%" do
		it "returns a correct value" do
			phi = Quadratic[5].new(1, 1) / 2
			expect(phi % (phi ** -1)).to eql(phi ** -2)
		end
	end

	describe "#<=>" do
		subject { x <=> y }

		context "when x < y" do
			let(:x) { Quadratic[2].new(2, 4) }
			let(:y) { Quadratic[3].new(-1, 5) }
			it { is_expected.to eql -1 }
		end

		context "when x == y" do
			let(:x) { Quadratic[2].new(3) / 2 }
			let(:y) { 1.5 }
			it { is_expected.to eql 0 }
		end

		context "when x > y" do
			let(:x) { Quadratic[3].new(-1, 5) }
			let(:y) { Quadratic[2].new(2, 4) }
			it { is_expected.to eql 1 }
		end

		context "when not comparable" do
			let(:x) { Quadratic[2].new(1, 1) }
			let(:y) { "(1+1\u221a2)" }
			it { is_expected.to be_nil }
		end
	end

	describe "#==" do
		subject { x == y }

		context "when x == y" do
			context "where y is Float" do
				let(:x) { Quadratic[5].new(1, 1) / 2 }
				let(:y) { 1.618033988749895 }
				it { is_expected.to be true }
			end

			context "where y is Quadratic::Imag" do
				let(:x) { Quadratic[5].new(1) }
				let(:y) { Quadratic[-3].new(1) }
				it { is_expected.to be true }
			end
		end

		context "when x != y" do
			let(:x) { Quadratic[3].new(1, 2) }
			let(:y) { Quadratic[2].new(1, 2) }
			it { is_expected.to be false }
		end

		context "when not comparable" do
			let(:x) { Quadratic[2].new(1, 1) }
			let(:y) { "(1+1\u221a2)" }
			it { is_expected.to be false }
		end
	end

	describe "#to_f" do
		it "returns a floating-point number" do
			expect(Quadratic[2].new(-665857, 470832).to_f).to eql -7.509119826032946e-07
		end
	end

	describe "#to_s" do
		it "returns a string" do
			val = -Quadratic[5].new(1, 1) / 2
			expect(val.to_s).to eql "((-1/2)-(1/2)*\u221a5)"
		end
	end
end
