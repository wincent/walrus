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

describe Walrus::Grammar::EchoDirective do
  class Accumulator
    attr_reader :content

    def initialize
      @content = ''
    end

    def accumulate string
      @content << string
    end
  end

  context 'compiled' do
    it 'should be able to round trip' do
      string              = Walrat::StringResult.new('hello world')
      string.source_text  = "'hello world'"
      @accumulator        = Accumulator.new
      @accumulator.instance_eval(Walrus::Grammar::EchoDirective.new(Walrus::Grammar::SingleQuotedStringLiteral.new(string)).compile)
      @accumulator.content.should == 'hello world'
    end

    # regression test for inputs that previously raised
    it 'should be able to recognize the short form' do
      @parser = Walrus::Parser.new
      expect do
        @parser.parse '#= Walrus::VERSION #'
      end.to_not raise_error
      expect do
        @parser.parse '<meta name="generator" content="Walrus #= Walrus::VERSION #">'
      end.to_not raise_error
    end
  end

  context 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to round trip' do
      # simple example
      Object.class_eval @parser.compile("#echo 'foo'", :class_name => :EchoDirectiveSpecAlpha)
      Walrus::Grammar::EchoDirectiveSpecAlpha.new.fill.should == 'foo'
    end

    it 'evaluates multiple expressions, but only accumulates the last' do
      Object.class_eval @parser.compile("#echo @foo = 1 + 2; @foo = @foo + 3; @foo",
                           :class_name => :EchoDirectiveSpecBeta)
      Walrus::Grammar::EchoDirectiveSpecBeta.new.fill.should == '6'
    end

    it 'evaluates multiple expressions in the same context' do
      # this means that local variables can be set in one expression in the
      # list and accessed by others in the list
      Object.class_eval @parser.compile("#echo foo = 1 + 2; foo = foo + 3; foo",
                           :class_name => :EchoDirectiveSpecDelta)
      Walrus::Grammar::EchoDirectiveSpecDelta.new.fill.should == '6'
    end
  end
end
