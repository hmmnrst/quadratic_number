require "spec_helper"

RSpec.describe Quadratic do
	describe ".[]" do
		subject { Quadratic[d] }

		context "with a non-integer" do
			let(:d) { 2.0 }
			it { expect { subject }.to raise_error TypeError, "not an integer" }
		end

		context "with an integer including square factors" do
			let(:d) { 12 }
			it { expect { subject }.to raise_error RangeError, "d must be square-free other than 0 or 1" }
		end

		context "with a positive square-free integer" do
			let(:d) { 5 }
			it "returns a subclass of Quadratic::Real" do
				klass = subject
				expect(klass).to be_kind_of Class
				expect(klass.superclass).to eq Quadratic::Real
				expect(klass.name).to eq "Quadratic[5]"
			end
		end

		context "with a negative square-free integer" do
			let(:d) { -1 }
			it "returns a subclass of Quadratic::Imag" do
				klass = subject
				expect(klass).to be_kind_of Class
				expect(klass.superclass).to eq Quadratic::Imag
				expect(klass.name).to eq "Quadratic[-1]"
			end
		end

		context "when called twice" do
			it "returns a same class" do
				klass1 = Quadratic[5]
				klass2 = Quadratic[5]
				klass3 = Quadratic[-1]
				expect(klass1).to equal klass2
				expect(klass1).not_to eq klass3
			end
		end
	end

	describe "#eql?" do
		context "when x and y are the same class" do
			context "when their components are eql respectively" do
				it "returns true" do
					x = Quadratic[-2].new(1, Rational(2, 1))
					y = Quadratic[-2].new(1, Rational(2, 1))
					expect(x.eql? y).to be true
					expect(x.hash).to eql y.hash
				end
			end

			context "when their components are not eql" do
				it "returns false" do
					x = Quadratic[-2].new(1, Rational(2, 1))
					y = Quadratic[-2].new(1, 2)
					expect(x.eql? y).to be false
				end
			end
		end

		context "when x and y are different classes" do
			it "returns false" do
				x = Quadratic[-2].new(0)
				y = Quadratic[-3].new(0)
				expect(x.eql? y).to be false
			end
		end
	end

	describe "#denominator" do
		it "returns a positive integer" do
			num = Quadratic[-3].new(Rational(-1, 6), Rational(-1, 4))
			expect(num.denominator).to eql 12
		end
	end

	describe "#numerator" do
		it "returns a quadratic number with integers" do
			num = Quadratic[-3].new(Rational(-1, 6), Rational(-1, 4))
			expect(num.numerator).to eql Quadratic[-3].new(-2, -3)
		end
	end

	describe "#qconj" do
		it "returns a quadratic conjugate" do
			num = Quadratic[5].new(1, 1) / 2
			expect(num.qconj).to eql(Quadratic[5].new(1, -1) / 2)
		end
	end

	describe "#trace" do
		it "returns a trace" do
			num = Quadratic[5].new(1, 1) / 2
			expect(num.trace).to eql Rational(1, 1)
		end
	end

	describe "#norm" do
		it "returns a norm" do
			num = Quadratic[5].new(1, 1) / 2
			expect(num.norm).to eql Rational(-1, 1)
		end
	end

	describe "#discriminant" do
		it "returns a discriminant" do
			num = Quadratic[5].new(1, 1) / 2
			expect(num.discriminant).to eql Rational(5, 1)
		end
	end
end
