# Copyright 2007-2009 Wincent Colaiuta
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rake'
require 'rake/gempackagetask'
require 'rubygems'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

desc 'Prepare release'
task :release => [:changelog, :gem]

desc 'Update changelog'
task :changelog do |t|
  system %{svn log svn://svn.wincent.com/Walrus/trunk > CHANGELOG.txt}
end

desc 'Run specs with coverage'
Spec::Rake::SpecTask.new('coverage') do |t|
  t.spec_files  = FileList['spec/**/*_spec.rb']
  t.rcov        = true
  t.rcov_opts = ['--exclude', "spec"]
end

desc 'Run specs'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files  = FileList['spec/**/*_spec.rb']
end

desc 'Verify that test coverage is above minimum threshold'
RCov::VerifyTask.new(:verify => :spec) do |t|
  t.threshold   = 99.2 # never adjust expected coverage down, only up
  t.index_html  = 'coverage/index.html'
end

desc 'Generate specdocs for inclusions in RDoc'
Spec::Rake::SpecTask.new('specdoc') do |t|
  t.spec_files  = FileList['spec/**/*_spec.rb']
  t.spec_opts   = ['--format', 'rdoc']
  t.out         = 'specdoc.rd'
end

desc 'Build C extensions'
task :make => :jindex

desc 'Build jindex extension'
task :jindex do |t|
  system %{cd ext/jindex && ruby ./extconf.rb && make && cp jindex.#{Config::CONFIG['DLEXT']} ../ && cd -}
end

SPEC = Gem::Specification.new do |s|
  s.name              = 'walrus'
  s.version           = '0.2'
  s.author            = 'Wincent Colaiuta'
  s.email             = 'win@wincent.com'
  s.homepage          = 'http://walrus.wincent.com/'
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
  s.files             = FileList['{bin,lib,spec}/**/*', 'ext/**/*.rb', 'ext/**/*.c'].to_a
  s.extensions        = ['ext/jindex/extconf.rb']
  s.executables       = ['walrus']
  s.add_runtime_dependency('wopen3', '>= 0.1')
  s.add_development_dependency('mkdtemp', '>= 1.0')
end

Rake::GemPackageTask.new(SPEC) do |t|
  t.need_tar      = true
end

