# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    describe 'a placeholder with no parameters' do
    
      setup do
        @parser = Parser.new
      end
      
      it 'should be substituted into the output' do
        placeholder = @parser.compile( <<-HERE
#set $foo = 'bar'
$foo
        HERE
        )
        self.class.class_eval(placeholder).should == "bar\n"
      end
            
    end
    
    describe 'a placeholder that accepts one parameter' do
      
      setup do
        @parser = Parser.new
      end
      
      it 'should be substituted into the output' do
        placeholder = @parser.compile( <<-HERE
#def foo(string)
#echo string.downcase
#end
$foo("HELLO WORLD")
        HERE
        )
        self.class.class_eval(placeholder).should == "hello world\n"
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

