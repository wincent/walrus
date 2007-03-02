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
      
      # corresponding array of expected output files
      @expected_output_paths = @template_paths.collect { |path| path.to_s.sub(/\.tmpl\z/i, ".expected") }
      
      # class names based on template filename (less ".tmpl" extension)
      @class_names = @template_paths.collect { |path| Pathname.new(path).basename.to_s.gsub(/\.tmpl\z/i, '').to_class_name } 
      
      # make temporary output dir for storing compiled templates
      tmpdir = Pathname.new(Dir.mkdtemp('/tmp/walrus.acceptance.XXXXXX'))
      
      @parser = Parser.new
      
      @template_paths.each_with_index do |template, index|
        
        class_name      = @class_names[index]
        compiled        = @parser.compile(IO.read(template), :class_name => class_name)
        expected_output = IO.read(@expected_output_paths[index])
        
        specify "actual output should match expected output evaluating dynamically (source file: #{template})" do
          actual_output = self.class.class_eval(compiled)
          actual_output.should == expected_output
        end
        
        specify "actual output should match expected output running compiled file in subshell (source file: #{template})" do
          target_path = tmpdir.join(class_name.to_require_name + '.rb')
          File.open(target_path, 'w+') { |file| file.puts compiled }
          actual_output = `ruby -I#{Walrus::SpecHelper::LIBDIR} -I#{Walrus::SpecHelper::EXTDIR} #{target_path}`
          actual_output.should == expected_output
        end
        
        specify "actual output should match expected output using 'walrus' commandline tool (source file: #{template})" do
          
        end
        
      end
      
    end
    
  end
  
end # module Walrus

