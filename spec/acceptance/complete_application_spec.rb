# Copyright 2010 Wincent Colaiuta. All rights reserved.
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
require 'wopen3'

describe 'processing a complete set of application documentation' do
  # must start with absolute paths because __FILE__ varies depending on the
  # spec invocation, which can cause specs to pass or fail inconsistently:
  #   - spec spec                                         -> relative __FILE__
  #   - spec spec/acceptance                              -> relative __FILE__
  #   - spec spec/acceptance/complete_application_spec.rb -> absolute __FILE__
  base_dir          = Pathname.new(File.dirname(__FILE__)).realpath
  relative_dir      = base_dir.relative_path_from Walrus::SpecHelper::BASE
  template_dir      = relative_dir + 'complete_application/en.lproj/help'
  all_templates     = Pathname.glob((template_dir + '**/*.tmpl').to_s)
  web_templates     = all_templates.reject { |t| t.to_s =~ %r{/autogen/} }
  search_additions  = "#{Walrus::SpecHelper::LIBDIR}:#{ENV['RUBYLIB']}"

  # NOTE: the buildtools specs must run first because the following specs
  # depend on the buildtools templates
  describe 'compiling the buildtools support templates' do
    buildtools_dir  = relative_dir + 'complete_application/buildtools/help'
    buildtools_templates = Pathname.glob((buildtools_dir + '**/*.tmpl').to_s)

    # we could compile all the templates in one batch, but prefer to
    # have finer-grained error messages in the event of a failure, so
    # do them one template at a time
    buildtools_templates.each do |t|
      describe "template: #{t}" do
        before :all do
          @result = Wopen3.system 'env', "RUBYLIB=#{search_additions}",
            'RUBYOPT=rrubygems', Walrus::SpecHelper::TOOL.to_s, 'compile',
            '--no-backup', t.to_s
        end

        it 'succeeds' do
          expect(@result).to be_success
        end
      end
    end
  end

  describe 'help book format' do
    all_templates.each do |t|
      describe "template: #{t}" do
        before :all do
          @output_dir = Pathname.new(Dir.mkdtemp '/tmp/walrus.acceptance.XXXXX')
        end

        describe 'compiling' do
          before :all do
            @result = Wopen3.system 'env', "RUBYLIB=#{search_additions}",
              'RUBYOPT=rrubygems', Walrus::SpecHelper::TOOL.to_s, 'compile',
              '--no-backup', t.to_s
          end

          it 'succeeds' do
            puts @result.stderr unless @result.success? # for debugging
            expect(@result).to be_success
          end
        end

        describe 'filling' do
          before :all do
            @result = Wopen3.system 'env', "RUBYLIB=#{search_additions}",
              'RUBYOPT=rrubygems', Walrus::SpecHelper::TOOL.to_s, 'fill',
              '--no-backup', '--output-dir', @output_dir.to_s, t.to_s
            @output_file = @output_dir + t.sub(/\.tmpl\z/, '')
          end

          it 'succeeds' do
            puts @result.stderr unless @result.success? # for debugging
            expect(@result).to be_success
          end

          it 'writes to the output file' do
            expect(@output_file).to exist
          end

          it 'produces matching output' do
            tidied_output = @output_file.sub(/\.html\z/, '.tidy.html')
            Wopen3.system 'tidy', '-utf8', '-wrap', '0', '--fix-uri', 'no',
              '--tidy-mark', 'no', '-quiet', '-o', tidied_output.to_s,
              @output_file.to_s, '\;'
            actual_output = tidied_output.read
            expected_output = t.sub(/\.tmpl\z/, '.app.html').read
            expect(actual_output).to eq(expected_output)
          end
        end
      end
    end
  end

  describe 'web format' do
    web_templates.each do |t|
      describe "template: #{t}" do
        before :all do
          @output_dir = Pathname.new(Dir.mkdtemp '/tmp/walrus.acceptance.XXXXX')
        end

        describe 'compiling' do
          before :all do
            @result = Wopen3.system 'env', "RUBYLIB=#{search_additions}",
              'RUBYOPT=rrubygems', 'WALRUS_STLYE=web',
              Walrus::SpecHelper::TOOL.to_s, 'compile', '--no-backup', t.to_s
          end

          it 'succeeds' do
            puts @result.stderr unless @result.success? # for debugging
            expect(@result).to be_success
          end
        end

        describe 'filling' do
          before :all do
            @result = Wopen3.system 'env', "RUBYLIB=#{search_additions}",
              'RUBYOPT=rrubygems', 'WALRUS_STYLE=web',
              Walrus::SpecHelper::TOOL.to_s, 'fill', '--no-backup',
              '--output-dir', @output_dir.to_s, t.to_s
            @output_file = @output_dir + t.sub(/\.tmpl\z/, '')
          end

          it 'succeeds' do
            puts @result.stderr unless @result.success? # for debugging
            expect(@result).to be_success
          end

          it 'writes to the output file' do
            expect(@output_file).to exist
          end

          it 'produces matching output' do
            tidied_output = @output_file.sub(/\.html\z/, '.tidy.html')
            Wopen3.system 'tidy', '-utf8', '-wrap', '0', '--fix-uri', 'no',
              '--tidy-mark', 'no', '-quiet', '-o', tidied_output.to_s,
              @output_file.to_s, '\;'
            actual_output = tidied_output.read
            expected_output = t.sub(/\.tmpl\z/, '.web.html').read
            expect(actual_output).to eq(expected_output)
          end
        end
      end
    end
  end
end
