# encoding: utf-8
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

describe Walrus::Grammar::RawDirective do
  class Accumulator
    attr_reader :content
    def initialize
      @content = ''
    end
    def accumulate(string)
      @content << string
    end
  end

  describe 'compiling a RawDirective instance' do
    it 'should be able to round trip' do
      @accumulator  = Accumulator.new
      @raw          = Walrus::Grammar::RawDirective.new('hello \'world\'\\... € #raw, $raw, \\raw')
      @accumulator.instance_eval(@raw.compile)
      @accumulator.content.should == 'hello \'world\'\\... € #raw, $raw, \\raw'
    end
  end

  describe 'producing a Document containing RawText' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to round trip' do
      # simple example
      Object.class_eval @parser.compile "#raw\nhello world\n#end",
        :class_name => :RawDirectiveSpecAlpha
      Walrus::Grammar::RawDirectiveSpecAlpha.new.fill.should == "hello world\n"

      # containing single quotes
      Object.class_eval @parser.compile "#raw\nhello 'world'\n#end",
        :class_name => :RawDirectiveSpecBeta
      Walrus::Grammar::RawDirectiveSpecBeta.new.fill.should == "hello 'world'\n"

      # containing a newline
      Object.class_eval @parser.compile "#raw\nhello\nworld\n#end",
        :class_name => :RawDirectiveSpecDelta
      Walrus::Grammar::RawDirectiveSpecDelta.new.fill.should == "hello\nworld\n"

      # using a "here document"
      Object.class_eval @parser.compile "#raw <<HERE
hello world
literal #end with no effect
HERE", :class_name => :RawDirectiveSpecGamma
      Walrus::Grammar::RawDirectiveSpecGamma.new.fill.should == "hello world\nliteral #end with no effect\n"

      # "here document", alternative syntax
      Object.class_eval @parser.compile "#raw <<-HERE
hello world
literal #end with no effect
      HERE", :class_name => :RawDirectiveSpecIota
      Walrus::Grammar::RawDirectiveSpecIota.new.fill.should == "hello world\nliteral #end with no effect\n"
    end
  end
end
