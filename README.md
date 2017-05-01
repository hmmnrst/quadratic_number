# Quadratic

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'quadratic_number'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install quadratic_number

## Usage

```ruby
require 'quadratic_number'

### construction ###
phi   = Quadratic[5].new(1, 1) / 2     #=> ((1/2)+(1/2)*√5)
omega = Quadratic[-3].new(-1, 1) / 2   #=> ((-1/2)+(1/2)*√-3)

### type conversion ###
phi.to_f      #=> 1.618033988749895
omega.to_c    #=> ((-1/2)+(0+(1/2)*√3)*i)
omega * 1.0   #=> (-0.5+0.8660254037844386i)

### calculation ###
phi ** 2 == phi + 1      #=> true
omega ** 2 + omega + 1   #=> ((0/1)+(0/1)*√-3)
phi * omega              #=> (-0.8090169943749475+1.4012585384440734i)

### quadratic equation ###
puts "x^2 - #{phi.trace} x + #{phi.norm} = 0  <-->  x = #{phi}, #{phi.qconj}"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hmmnrst/quadratic_number.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

