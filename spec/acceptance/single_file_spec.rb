# Copyright 2007-2010 Wincent Colaiuta. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require File.expand_path('../spec_helper', File.dirname(__FILE__))
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
