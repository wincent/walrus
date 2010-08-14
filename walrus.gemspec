require File.expand_path('lib/walrus/version.rb', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name              = 'walrus'
  s.version           = Walrus::VERSION
  s.author            = 'Wincent Colaiuta'
  s.email             = 'win@wincent.com'
  s.homepage          = 'https://wincent.com/products/walrus'
  s.rubyforge_project = 'walrus'
  s.platform          = Gem::Platform::RUBY
  s.summary           = 'Object-oriented templating system'
  s.description       = <<-ENDDESC
    Walrus is an object-oriented templating system inspired by and similar
    to the Cheetah Python-powered template engine. It includes a Parser
    Expression Grammar (PEG) parser generator capable of generating an
    integrated lexer, "packrat" parser, and Abstract Syntax Tree (AST)
    builder.
  ENDDESC
  s.require_paths     = ['lib', 'ext']
  s.has_rdoc          = true

  # TODO: add 'docs' subdirectory, 'README.txt' when they're done
  s.files             = Dir['bin/walrus', 'lib/**/*.rb', 'ext/*.{c,rb}']
  s.extensions        = ['ext/extconf.rb']
  s.executables       = ['walrus']
  s.add_runtime_dependency('wopen3', '>= 0.1')
  s.add_development_dependency('mkdtemp', '>= 1.0')
  s.add_development_dependency('rspec', '1.3.0')
end
