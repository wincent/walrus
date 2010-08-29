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

describe Walrus::Grammar::MultilineComment do
  context 'compiling' do
    it 'comments should produce no meaningful output' do
      eval(Walrus::Grammar::MultilineComment.new(" hello\n   world ").compile).should == nil
    end
  end

  describe 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should produce no output' do
      # simple multiline comment
      Object.class_eval @parser.compile("#* hello\n   world *#", :class_name => :MultilineCommentSpecAlpha)
      Walrus::Grammar::MultilineCommentSpecAlpha.new.fill.should == ''

      # nested singleline comment
      Object.class_eval @parser.compile("#* hello ## <-- first line\n   world *#", :class_name => :MultilineCommentSpecBeta)
      Walrus::Grammar::MultilineCommentSpecBeta.new.fill.should == ''

      # nested multiline comment
      Object.class_eval @parser.compile("#* hello ## <-- first line\n   world #* <-- second line *# *#", :class_name => :MultilineCommentSpecDelta)
      Walrus::Grammar::MultilineCommentSpecDelta.new.fill.should == ''

      # multiple comments
      Object.class_eval @parser.compile("#* hello *##* world *#", :class_name => :MultilineCommentSpecGamma)
      Walrus::Grammar::MultilineCommentSpecGamma.new.fill.should == ''
    end
  end
end
