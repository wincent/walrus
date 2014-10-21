# encoding: utf-8
# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

module Walrus
  using StringAdditions

  describe 'converting to source strings' do
    it 'standard strings should be unchanged' do
      expect(''.to_source_string).to eq('')
      expect('hello world'.to_source_string).to eq('hello world')
      expect("hello\nworld".to_source_string).to eq("hello\nworld")
    end

    it 'single quotes should be escaped' do
      expect("'foo'".to_source_string).to eq("\\'foo\\'")
    end

    it 'backslashes should be escaped' do
      expect('hello\\nworld'.to_source_string).to eq("hello\\\\nworld")
    end

    it 'should work with Unicode characters' do
      expect('€ información…'.to_source_string).to eq('€ información…')
    end

    it 'should be able to round trip' do
      expect(eval("'" + ''.to_source_string + "'")).to eq('')
      expect(eval("'" + 'hello world'.to_source_string + "'")).to eq('hello world')
      expect(eval("'" + "hello\nworld".to_source_string + "'")).to eq("hello\nworld")
      expect(eval("'" + "'foo'".to_source_string + "'")).to eq('\'foo\'')
      expect(eval("'" + 'hello\\nworld'.to_source_string + "'")).to eq('hello\\nworld')
      expect(eval("'" + '€ información…'.to_source_string + "'")).to eq('€ información…')
    end
  end
end
