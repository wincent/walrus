# encoding: utf-8
# Copyright 2007-2010 Wincent Colaiuta
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../spec_helper', File.dirname(__FILE__))

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
