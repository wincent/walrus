# $Id$

require 'rake'
require 'rubygems'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

desc 'Install'
task :install do
  raise 'Not yet implemented'
end

desc 'Run specs with coverage'
Spec::Rake::SpecTask.new('coverage') do |t|
  t.spec_files  = FileList['spec/**/*_spec.rb']
  t.rcov        = true
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
task :make => [:jindex, :mkdtemp]

desc 'Build jindex extension'
task :jindex do |t|
  system %{cd ext/jindex && ruby ./extconf.rb && make && cp jindex.bundle ../ && cd -}
end

desc 'Build mkdtemp extension'
task :mkdtemp do |t|
  system %{cd ext/mkdtemp && ruby ./extconf.rb && make && cp mkdtemp.bundle ../ && cd -}
end

Gem::manage_gems
require 'rake/gempackagetask'
SPEC = Gem::Specification.new do |s|
  s.name          = 'Walrus'
  s.version       = '0.1'
  s.author        = 'Wincent Colaiuta'
  s.email         = 'win@wincent.com'
  s.homepage      = 'http://walrus.wincent.com/'
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'Object-oriented templating system'
  s.require_paths = ['lib', 'ext']
  s.autorequire   = 'walrus'
  s.has_rdoc      = true
  s.files         = FileList['{bin,ext,docs,lib,spec}/**/*'].to_a
  s.extensions    = ['ext/jindex/extconf.rb', 'ext/mkdtemp/extconf.rb']
end

Rake::GemPackageTask.new(SPEC) do |t|
  t.need_tar      = true
end
