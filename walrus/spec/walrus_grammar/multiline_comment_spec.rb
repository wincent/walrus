# Copyright 2007 Wincent Colaiuta
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
#
# $Id: multiline_comment_spec.rb 192 2007-05-03 09:27:35Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  
  class WalrusGrammar
    
    describe 'compiling a comment instance' do
      
      it 'comments should produce no meaningful output' do
        self.class.class_eval(MultilineComment.new(" hello\n   world ").compile).should == nil
      end
      
    end
    
    describe 'producing a Document containing Comment' do
      
      before(:each) do
        @parser = Parser.new
      end
      
      it 'should produce no output' do
        
        # simple multiline comment
        comment = @parser.compile("#* hello\n   world *#", :class_name => :MultilineCommentSpecAlpha)
        self.class.class_eval(comment)
        self.class::Walrus::WalrusGrammar::MultilineCommentSpecAlpha.new.fill.should == ''
        
        # nested singleline comment
        comment = @parser.compile("#* hello ## <-- first line\n   world *#", :class_name => :MultilineCommentSpecBeta)
        self.class.class_eval(comment)
        self.class::Walrus::WalrusGrammar::MultilineCommentSpecBeta.new.fill.should == ''
        
        # nested multiline comment
        comment = @parser.compile("#* hello ## <-- first line\n   world #* <-- second line *# *#", :class_name => :MultilineCommentSpecDelta)
        self.class.class_eval(comment)
        self.class::Walrus::WalrusGrammar::MultilineCommentSpecDelta.new.fill.should == ''
        
        # multiple comments
        comment = @parser.compile("#* hello *##* world *#", :class_name => :MultilineCommentSpecGamma)
        self.class.class_eval(comment)
        self.class::Walrus::WalrusGrammar::MultilineCommentSpecGamma.new.fill.should == ''
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

