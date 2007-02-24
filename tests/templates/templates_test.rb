#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require '../test_helper' if not defined?(Walrus::TestHelper)
require 'walrus/diff'
require 'walrus/template'
require 'walrus/additions/test/unit/error_collector'

module Walrus
  
  # This class performs high-level testing by running Walrus on the sample templates in the subdirectories of the "tests/templates/" directory and comparing them with the expected output.
  class TemplatesTest < Test::Unit::TestCase
  
    include Test::Unit::ErrorCollector
  
    # Returns an array of absolute paths indicating the location of all testable templates.
    def template_paths
      Dir[File.join(File.dirname(__FILE__), '**/*.tmpl')].collect { |template| Pathname.new(template).realpath }
    end
  
    # Given the path of an input template returns the path of the file containing the expected output for the template.
    def expected_path(template)
      raise ArgumentError.new("template must not be nil") if template.nil?
      expected = template.sub(/\.tmpl$/i, ".expected")
      raise "could not calculate expected filename" if expected == template
      expected
    end
  
    # Returns a string containing the expected output for the test.
    def expected_output(template)
    
      raise "template must not be nil" if template.nil?
      expected = self.expected_path(template)
      raise "expected output file does not exist" unless File.exist?(expected)
    
      # read the file off the disk
      output = nil
      File.open(expected, "r") { |file| output = file.read }
      raise "failed to read file" if output == nil
      output
    end
  
    # Obtains the actual ouput for the specified template with the assistance of the walrus command line tool.
    def actual_output_using_tool(template)
    
    end
  
    # Obtains the actual output for the specified template without the assistance of the walrus command line tool.
    # Reads the template in from disk, initializes a new Tempalte object, and invokes the fill method.   
    def actual_output_bypassing_tool(template)
      raise "template must not be nil" if template.nil?
      Walrus::Template.new(template).fill    
    end
  
    # Tests the output of all testable templates (as identified by the template_paths method) using the walrus command line tool.
    def test_templates_using_tool
      # TODO: write tool tests
    end
  
    # Tests the output of all testable templates (as identified by the template_paths method) directly (without using the walrus command line tool).
    def test_templates_bypassing_tool
      self.template_paths.each do |template|
        collecting_errors do
          expected  = self.expected_output(template)
          actual    = self.actual_output_bypassing_tool(template)
        
          # diagnostic purposes: include diff with error message
          diff = "left: %s, right: %s\n" % [ self.expected_path(template), template ]
          if actual != expected
            actual = "(nil!)" if actual.nil?
            diff << Diff.new(self.expected_path(template), actual).to_s
          end
          assert_equal expected, actual, diff
        end
      end
    end
    
  end # class TemplatesTest
end # module Walrus

