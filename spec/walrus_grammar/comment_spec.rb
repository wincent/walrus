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

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    describe 'compiling a comment instance' do
      
      it 'comments should produce no meaningful output' do
        eval(Comment.new(' hello world').compile).should == nil
      end
      
    end
    
    describe 'producing a Document containing Comment' do
      
      before(:each) do
        @parser = Parser.new
      end
      
      it 'should produce no output' do
        comment = @parser.compile('## hello world', :class_name => :CommentSpec)
        self.class.class_eval(comment)
        self.class::Walrus::WalrusGrammar::CommentSpec.new.fill.should == ''
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

