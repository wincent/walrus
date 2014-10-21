# Copyright 2010-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'
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
