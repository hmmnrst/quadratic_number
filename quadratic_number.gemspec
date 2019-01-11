lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "quadratic_number"
  spec.version       = "0.1.0"
  spec.authors       = ["Masahiro Nomoto"]
  spec.email         = ["hmmnrst@users.noreply.github.com"]

  spec.summary       = %q{Quadratic class}
  spec.description   = %q{Provides a numeric class Quadratic to represent a+b√d exactly}
  spec.homepage      = "https://github.com/hmmnrst/quadratic_number"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
