# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Grammar::SilentDirective do
  context 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'produces no output' do
      Object.class_eval @parser.compile "#silent 'foo'",
        :class_name => :SilentDirectiveSpecAlpha
      expect(Walrus::Grammar::SilentDirectiveSpecAlpha.new.fill).to eq('')
    end
  end
end
