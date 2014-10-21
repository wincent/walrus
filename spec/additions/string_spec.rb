# encoding: utf-8
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
