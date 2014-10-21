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
      expect(directive.column_start).to eq(0)
      expect(directive.expression.target.column_start).to eq(6)
      expect(directive.expression.message.column_start).to eq(13)

      pending 'proper boundary detection requires massive changes to the algorithm'
      expect(directive.expression.column_start).to eq(6)                 # currently returns: 0
      expect(directive.expression.source_text).to eq('string.downcase')  # currently returns: #echo string.downcase

    end
  end
end
