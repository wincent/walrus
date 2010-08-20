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

describe Walrus::Grammar::MultilineComment do
  context 'compiling' do
    it 'comments should produce no meaningful output' do
      eval(Walrus::Grammar::MultilineComment.new(" hello\n   world ").compile).should == nil
    end
  end

  describe 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should produce no output' do
      # simple multiline comment
      eval @parser.compile("#* hello\n   world *#", :class_name => :MultilineCommentSpecAlpha)
      Walrus::Grammar::MultilineCommentSpecAlpha.new.fill.should == ''

      # nested singleline comment
      eval @parser.compile("#* hello ## <-- first line\n   world *#", :class_name => :MultilineCommentSpecBeta)
      Walrus::Grammar::MultilineCommentSpecBeta.new.fill.should == ''

      # nested multiline comment
      eval @parser.compile("#* hello ## <-- first line\n   world #* <-- second line *# *#", :class_name => :MultilineCommentSpecDelta)
      Walrus::Grammar::MultilineCommentSpecDelta.new.fill.should == ''

      # multiple comments
      eval @parser.compile("#* hello *##* world *#", :class_name => :MultilineCommentSpecGamma)
      Walrus::Grammar::MultilineCommentSpecGamma.new.fill.should == ''
    end
  end
end
