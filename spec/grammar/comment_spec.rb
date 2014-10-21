# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::Comment do
  context 'compiled' do
    it 'produces no meaningful output' do
      eval(Walrus::Grammar::Comment.new(' hello world').compile).should == nil
    end
  end

  context 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'produces no output' do
      Object.class_eval @parser.compile('## hello world', :class_name => :CommentSpec)
      Walrus::Grammar::CommentSpec.new.fill.should == ''
    end
  end
end
