# Copyright 2007 Wincent Colaiuta
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

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing
require 'mkdtemp'

# This spec performs high-level acceptance testing by running Walrus on the sample templates in the subdirectories of the "spec/acceptance/" directory and comparing them with the expected output.
describe 'processing test files with Walrus' do
  # construct an array of absolute paths indicating the location of all testable templates.
  template_paths = Dir[File.join(File.dirname(__FILE__), '**/*.tmpl')].collect { |template| Pathname.new(template).realpath }

  # make temporary output dirs for storing compiled templates
  manually_compiled_templates = Pathname.new(Dir.mkdtemp('/tmp/walrus.acceptance.XXXXXX'))
  walrus_compiled_templates   = Pathname.new(Dir.mkdtemp('/tmp/walrus.acceptance.XXXXXX'))
  parser                      = Walrus::Parser.new
  search_additions            = "#{ENV['RUBYLIB']}:#{Walrus::SpecHelper::LIBDIR}:#{Walrus::SpecHelper::EXTDIR}"

  template_paths.each do |path|
    template        = Walrus::Template.new(path)
    compiled        = nil
    it 'template should compile (source file: #{path})' do
      compiled      = template.compile
    end
    next if compiled.nil? # compiled will be nil if the compilation spec failed

    expected_output = IO.read(path.to_s.sub(/\.tmpl\z/i, ".expected"))

    it "actual output should match expected output evaluating dynamically (source file: #{path})" do
      actual_output = template.fill
      actual_output.should == expected_output
    end

    it "actual output should match expected output running compiled file in subshell (source file: #{path})" do
      target_path = manually_compiled_templates.join(path.basename(path.extname).to_s + '.rb')
      File.open(target_path, 'w+') { |file| file.puts compiled }
      actual_output = `ruby -I#{Walrus::SpecHelper::LIBDIR} -I#{Walrus::SpecHelper::EXTDIR} #{target_path}`
      actual_output.should == expected_output
    end

    it "actual output should match expected output using 'walrus' commandline tool (source file: #{path})" do
      `env RUBYLIB='#{search_additions}' #{Walrus::SpecHelper::TOOL} fill --output-dir '#{walrus_compiled_templates}' '#{path}'`
      dir, base = path.split
      dir   = dir.to_s.sub(/\A\//, '') if dir.absolute? # and always will be absolute
      base  = base.basename(base.extname).to_s + '.html'
      actual_output = IO.read(walrus_compiled_templates + dir + base)
      actual_output.should == expected_output
    end
  end
end

# These templates have a different extension to keep them separate from the other acceptance tests.
describe 'processing multiple-interdependent files with Walrus' do
  template_paths  = Dir[File.join(File.dirname(__FILE__), '**/*.complex')].collect { |template| Pathname.new(template).realpath }
  output_dir      = Pathname.new(Dir.mkdtemp('/tmp/walrus.acceptance.XXXXXX'))
  parser          = Walrus::Parser.new

  search_additions  = "#{ENV['RUBYLIB']}:#{Walrus::SpecHelper::LIBDIR}:#{Walrus::SpecHelper::EXTDIR}"

  template_paths.each do |path|
    it 'should be able to compile all the templates' do
      `env RUBYLIB='#{search_additions}' #{Walrus::SpecHelper::TOOL} compile --input-extension complex --output-dir '#{output_dir}' '#{path}'`
    end
  end

  template_paths.each do |path|
    it 'should be able to fill all the templates' do
      `env RUBYLIB='#{search_additions}' #{Walrus::SpecHelper::TOOL} fill --input-extension complex --output-dir '#{output_dir}' '#{path}'`
      dir, base = path.split
      dir   = dir.to_s.sub(/\A\//, '') if dir.absolute? # and always will be absolute
      base  = base.basename(base.extname).to_s + '.html'
      actual_output   = IO.read(output_dir + dir + base)
      expected_output = IO.read(path.to_s.sub(/\.complex\z/i, ".expected"))
      actual_output.should == expected_output
    end
  end
end
