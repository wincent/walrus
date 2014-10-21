# Copyright 2007-2014 Greg Hurrell. All rights reserved.
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

describe Walrus::Grammar::Placeholder do
  describe 'a placeholder with no parameters' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be substituted into the output' do
      Object.class_eval @parser.compile "#set $foo = 'bar'\n$foo",
        :class_name => :PlaceholderSpecAlpha
      Walrus::Grammar::PlaceholderSpecAlpha.new.fill.should == 'bar'
    end
  end

  describe 'a placeholder that accepts one parameter' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be substituted into the output' do
      Object.class_eval @parser.compile %q{#def foo(string)
#echo string.downcase
#end
$foo("HELLO WORLD")}, :class_name => :PlaceholderSpecBeta
      Walrus::Grammar::PlaceholderSpecBeta.new.fill.should == "hello world"
    end
  end
end
