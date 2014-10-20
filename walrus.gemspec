# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require File.expand_path('lib/walrus/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.author                = 'Greg Hurrell'
  s.email                 = 'greg@hurrell.net'
  s.has_rdoc              = true
  s.homepage              = 'https://wincent.com/products/walrus'
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
  s.add_development_dependency 'rspec', '1.3.0'
  s.add_development_dependency 'yard'
end
