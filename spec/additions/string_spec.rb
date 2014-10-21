# encoding: utf-8
# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe 'converting to source strings' do
  it 'standard strings should be unchanged' do
    ''.to_source_string.should == ''
    'hello world'.to_source_string.should == 'hello world'
    "hello\nworld".to_source_string.should == "hello\nworld"
  end

  it 'single quotes should be escaped' do
    "'foo'".to_source_string.should == "\\'foo\\'"
  end

  it 'backslashes should be escaped' do
    'hello\\nworld'.to_source_string.should == "hello\\\\nworld"
  end

  it 'should work with Unicode characters' do
    '€ información…'.to_source_string.should == '€ información…'
  end

  it 'should be able to round trip' do
    eval("'" + ''.to_source_string + "'").should == ''
    eval("'" + 'hello world'.to_source_string + "'").should == 'hello world'
    eval("'" + "hello\nworld".to_source_string + "'").should == "hello\nworld"
    eval("'" + "'foo'".to_source_string + "'").should == '\'foo\''
    eval("'" + 'hello\\nworld'.to_source_string + "'").should == 'hello\\nworld'
    eval("'" + '€ información…'.to_source_string + "'").should == '€ información…'
  end
end
