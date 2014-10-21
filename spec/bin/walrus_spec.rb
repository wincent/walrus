# Copyright 2010-2014 Greg Hurrell. All rights reserved.
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
