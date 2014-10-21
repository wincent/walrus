# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'
require 'mkdtemp'

# This spec performs high-level acceptance testing by running Walrus on the
# sample templates in the subdirectories of the "spec/acceptance/" directory
# and comparing them with the expected output.
describe 'processing test files with Walrus' do
  # construct an array of absolute paths indicating the location of all
  # testable templates.
  template_paths = Dir[File.join(File.dirname(__FILE__), 'single_file/**/*.tmpl')].map { |template| Pathname.new(template).realpath }

  # make temporary output dirs for storing compiled templates
  manually_compiled_templates = Pathname.new(Dir.mkdtemp('/tmp/walrus.acceptance.XXXXXX'))
  walrus_compiled_templates   = Pathname.new(Dir.mkdtemp('/tmp/walrus.acceptance.XXXXXX'))
  search_additions            = "#{ENV['RUBYLIB']}:#{Walrus::SpecHelper::LIBDIR}"

  template_paths.each do |path|
    template        = Walrus::Template.new(path)
    compiled        = nil
    it "compiles (source file: #{path})" do
      compiled      = template.compile
    end
    next if compiled.nil? # compiled will be nil if the compilation spec failed

    expected_output = IO.read(path.to_s.sub(/\.tmpl\z/i, ".expected"))

    it "matches expected output when evaluating dynamically (source file: #{path})" do
      actual_output = template.fill
      expect(actual_output).to eq(expected_output)
    end

    it "matches expected output when running compiled file in subshell (source file: #{path})" do
      target_path = manually_compiled_templates.join(path.basename(path.extname).to_s + '.rb')
      File.open(target_path, 'w+') { |file| file.puts compiled }
      actual_output = `ruby -I#{Walrus::SpecHelper::LIBDIR} #{target_path}`
      expect(actual_output).to eq(expected_output)
    end

    it "matches expected output when using 'walrus' commandline tool (source file: #{path})" do
      `env RUBYLIB='#{search_additions}' #{Walrus::SpecHelper::TOOL} fill --output-dir '#{walrus_compiled_templates}' '#{path}'`
      dir, base = path.split
      dir   = dir.to_s.sub(/\A\//, '') if dir.absolute? # and always will be absolute
      base  = base.basename(base.extname).to_s
      actual_output = IO.read(walrus_compiled_templates + dir + base)
      expect(actual_output).to eq(expected_output)
    end
  end
end
