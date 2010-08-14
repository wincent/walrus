# Copyright 2007-2010 Wincent Colaiuta
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
require 'rubygems'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require File.expand_path('lib/walrus/version', File.dirname(__FILE__))

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

file 'ext/jindex/Makefile' => 'ext/jindex/extconf.rb' do
  Dir.chrdir 'ext/jindex' do
    ruby 'extconf.rb'
  end
end

EXT_FILE_DEPENDENCIES = Dir['ext/jindex/Makefile', 'ext/jindex/*.{rb,c}']
EXT_FILE = "ext/jindex.#{Config::CONFIG['DLEXT']}"
file EXT_FILE => EXT_FILE_DEPENDENCIES do
  Dir.chdir 'ext/jindex' do
    sh "make && cp jindex.#{Config::CONFIG['DLEXT']} ../"
  end
end

desc 'Build jindex extension'
task :jindex => EXT_FILE

BUILT_GEM_DEPENDENCIES = Dir[
  EXT_FILE,
  'lib/**/*.rb'
]

BUILT_GEM = "walrus-#{Walrus::VERSION}.gem"
file BUILT_GEM => BUILT_GEM_DEPENDENCIES do
  sh 'gem build walrus.gemspec'
end

desc 'Build gem ("gem build")'
task :build => BUILT_GEM

desc 'Publish gem ("gem push")'
task :push => :build do
  sh "gem push #{BUILT_GEM}"
end
