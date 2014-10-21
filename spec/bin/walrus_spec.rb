# Copyright 2010-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'
require 'walrus/runner' # for exit codes
require 'mkdtemp'
require 'wopen3'

# see also the specs in the spec/acceptance directory, which exercise
# bin/walrus extensively
describe 'bin/walrus' do
  def load_path
    path = Walrus::SpecHelper::LIBDIR
    path += ":#{ENV['RUBYLIB']}" if ENV['RUBYLIB']
    path
  end

  def walrus *args
    Wopen3.system 'env', "RUBYLIB=#{load_path}",
      Walrus::SpecHelper::TOOL.to_s, *args
  end

  describe 'regressions' do
    specify 'non-fatal errors should produce non-zero exit codes' do
      # fixed in commit a9e4646
      Dir.mkdtemp do
        result = walrus 'compile', 'non-existent-template'
        expect(result.stderr).to match(/failed to read input template/)
        expect(result.status).to eq(Walrus::Exit::READ_ERROR)
      end
    end

    specify 'directory arguments should not trigger infinite recursion' do
      # fixed in commit 6d23968
      dir = Dir.mkdtemp
      result = walrus 'compile', dir
      expect(result).to be_success
    end
  end
end
