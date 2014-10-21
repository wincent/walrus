# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::Comment do
  context 'compiled' do
    it 'produces no meaningful output' do
      expect(eval(Walrus::Grammar::Comment.new(' hello world').compile)).to eq(nil)
    end
  end

  context 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'produces no output' do
      Object.class_eval @parser.compile('## hello world', :class_name => :CommentSpec)
      expect(Walrus::Grammar::CommentSpec.new.fill).to eq('')
    end
  end
end
