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

desc 'Prepare release'
task :release => [:changelog, :gem]

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

desc 'Build gem ("gem build")'
task :build do
  sh 'gem build walrus.gemspec'
end

desc 'Publish gem ("gem push")'
task :push => :build do
  sh "gem push walrus-#{Walrus::VERSION}.gem"
end
