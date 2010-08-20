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

describe Walrus::Grammar::DoubleQuotedStringLiteral do
  context 'compiling' do
    it 'should produce a string literal' do
      string = Walrat::StringResult.new('hello world')
      string.source_text = '"hello world"'
      compiled = Walrus::Grammar::DoubleQuotedStringLiteral.new(string).compile
      compiled.should == '"hello world"'
      eval(compiled).should == 'hello world'
    end
  end
end

describe Walrus::Grammar::SingleQuotedStringLiteral do
  context 'compiling' do
    it 'should produce a string literal' do
      string = Walrat::StringResult.new('hello world')
      string.source_text = "'hello world'"
      compiled = Walrus::Grammar::SingleQuotedStringLiteral.new(string).compile
      compiled.should == "'hello world'"
      eval(compiled).should == 'hello world'
    end
  end
end
