# -*- encoding: utf-8 -*-
root = File.expand_path('../', __FILE__)
lib = "#{root}/lib"

$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "executer"
  s.version     = '0.1.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tung Nguyen"]
  s.email       = ["tongueroo@gmail.com"]
  s.homepage    = "https://github.com/tongueroo/executer"
  s.summary     = %q{A daemon that executes commands given to it}
  s.description = %q{}

  s.executables = `cd #{root} && git ls-files bin/*`.split("\n").collect { |f| File.basename(f) }
  s.files = `cd #{root} && git ls-files`.split("\n")
  s.require_paths = %w(lib)
  s.test_files = `cd #{root} && git ls-files -- {features,test,spec}/*`.split("\n")

  s.add_development_dependency "rspec", "~> 1.0"

  s.add_dependency "redis", "~> 2.2.2"
  s.add_dependency "yajl-ruby", "~> 1.0.0"
end