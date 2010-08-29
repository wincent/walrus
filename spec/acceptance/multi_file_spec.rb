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
      actual_output.should == expected_output
    end
  end
end
