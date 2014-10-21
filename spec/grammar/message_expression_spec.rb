# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::MessageExpression do
  describe 'calling source_text on a message expression inside an echo directive' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should return the text of the expression only' do
      directive = @parser.parse '#echo string.downcase'
      directive.column_start.should == 0
      directive.expression.target.column_start.should == 6
      directive.expression.message.column_start.should == 13

      pending 'proper boundary detection requires massive changes to the algorithm'
      directive.expression.column_start.should == 6                 # currently returns: 0
      directive.expression.source_text.should == 'string.downcase'  # currently returns: #echo string.downcase

    end
  end
end
