# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::MultilineComment do
  context 'compiling' do
    it 'comments should produce no meaningful output' do
      expect(eval(Walrus::Grammar::MultilineComment.new(" hello\n   world ").compile)).to eq(nil)
    end
  end

  describe 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should produce no output' do
      # simple multiline comment
      Object.class_eval @parser.compile("#* hello\n   world *#", :class_name => :MultilineCommentSpecAlpha)
      expect(Walrus::Grammar::MultilineCommentSpecAlpha.new.fill).to eq('')

      # nested singleline comment
      Object.class_eval @parser.compile("#* hello ## <-- first line\n   world *#", :class_name => :MultilineCommentSpecBeta)
      expect(Walrus::Grammar::MultilineCommentSpecBeta.new.fill).to eq('')

      # nested multiline comment
      Object.class_eval @parser.compile("#* hello ## <-- first line\n   world #* <-- second line *# *#", :class_name => :MultilineCommentSpecDelta)
      expect(Walrus::Grammar::MultilineCommentSpecDelta.new.fill).to eq('')

      # multiple comments
      Object.class_eval @parser.compile("#* hello *##* world *#", :class_name => :MultilineCommentSpecGamma)
      expect(Walrus::Grammar::MultilineCommentSpecGamma.new.fill).to eq('')
    end
  end
end
