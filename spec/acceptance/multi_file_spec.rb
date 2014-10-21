# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'
require 'mkdtemp'

describe 'processing multiple-interdependent files with Walrus' do
  template_paths  = Dir[File.join(File.dirname(__FILE__), 'multi_file/**/*.tmpl')].map { |template| Pathname.new(template).realpath }
  output_dir      = Pathname.new(Dir.mkdtemp('/tmp/walrus.acceptance.XXXXXX'))

  search_additions  = "#{Walrus::SpecHelper::LIBDIR}:#{ENV['RUBYLIB']}"

  template_paths.each do |path|
    it "compiles all the templates (source file: #{path})" do
      `env RUBYLIB='#{search_additions}' #{Walrus::SpecHelper::TOOL} compile --output-dir '#{output_dir}' '#{path}'`
    end
  end

  template_paths.each do |path|
    it "fills all the templates (source file: #{path})" do
      `env RUBYLIB='#{search_additions}' #{Walrus::SpecHelper::TOOL} fill --output-dir '#{output_dir}' '#{path}'`
      dir, base = path.split
      dir   = dir.to_s.sub(/\A\//, '') if dir.absolute? # and always will be absolute
      base  = base.basename(base.extname).to_s
      actual_output   = IO.read(output_dir + dir + base)
      expected_output = IO.read(path.to_s.sub(/\.tmpl\z/i, ".expected"))
      expect(actual_output).to eq(expected_output)
    end
  end
end
