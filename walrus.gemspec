# Copyright 2007-present Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require File.expand_path('lib/walrus/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.author                = 'Greg Hurrell'
  s.email                 = 'greg@hurrell.net'
  s.has_rdoc              = true
  s.homepage              = 'https://github.com/wincent/walrus'
  s.name                  = 'walrus'
  s.platform              = Gem::Platform::RUBY
  s.require_paths         = ['lib']
  s.required_ruby_version = '~> 2.1.0'
  s.rubyforge_project     = 'walrus'
  s.summary               = 'Object-oriented templating system'
  s.version               = Walrus::VERSION
  s.description           = <<-DESC
    Walrus is an object-oriented templating system inspired by and similar
    to the Cheetah Python-powered template engine.
  DESC

  # TODO: add 'docs' subdirectory, 'README.txt' when they're done
  s.files             = Dir['bin/walrus', 'lib/**/*.rb']
  s.executables       = ['walrus']
  s.add_runtime_dependency 'walrat', '0.2'
  s.add_development_dependency 'wopen3', '>= 0.3'
  s.add_development_dependency 'mkdtemp', '>= 1.0'
  s.add_development_dependency 'rspec', '~> 3.1.0'
  s.add_development_dependency 'yard'
end
