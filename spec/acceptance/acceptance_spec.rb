# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing
require 'mkdtemp'
require 'open3'

module Walrus
  
  class WalrusGrammar
    
    # This spec performs high-level acceptance testing by running Walrus on the sample templates in the subdirectories of the "spec/acceptance/" directory and comparing them with the expected output.
    context 'processing test files with Walrus' do
      
      # construct an array of absolute paths indicating the location of all testable templates.
      @template_paths = Dir[File.join(File.dirname(__FILE__), '**/*.tmpl')].collect { |template| Pathname.new(template).realpath }
      
      # make temporary output dir for storing compiled templates
      tmpdir = Pathname.new(Dir.mkdtemp('/tmp/walrus.acceptance.XXXXXX'))
      
      @parser = Parser.new
      
      @template_paths.each do |path|
        
        template        = Template.new(path)
        compiled        = template.compile
        expected_output = IO.read(path.to_s.sub(/\.tmpl\z/i, ".expected"))
        
        specify "actual output should match expected output evaluating dynamically (source file: #{path})" do
          actual_output = template.fill
          actual_output.should == expected_output
        end
        
        specify "actual output should match expected output running compiled file in subshell (source file: #{path})" do
          target_path = tmpdir.join(path.basename(path.extname).to_s + '.rb')
          File.open(target_path, 'w+') { |file| file.puts compiled }
          actual_output = `ruby -I#{Walrus::SpecHelper::LIBDIR} -I#{Walrus::SpecHelper::EXTDIR} #{target_path}`
          actual_output.should == expected_output
        end
        
        specify "actual output should match expected output using 'walrus' commandline tool (source file: #{path})" do
          
        end
        
      end
      
    end
    
  end
  
end # module Walrus

