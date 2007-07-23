# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: placeholder_spec.rb 192 2007-05-03 09:27:35Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  class WalrusGrammar
    
    describe 'a placeholder with no parameters' do
    
      before(:each) do
        @parser = Parser.new
      end
      
      it 'should be substituted into the output' do
        placeholder = @parser.compile("#set $foo = 'bar'\n$foo", :class_name => :PlaceholderSpecAlpha)
        self.class.class_eval(placeholder)
        self.class::Walrus::WalrusGrammar::PlaceholderSpecAlpha.new.fill.should == 'bar'
      end
            
    end
    
    describe 'a placeholder that accepts one parameter' do
      
      before(:each) do
        @parser = Parser.new
      end
      
      it 'should be substituted into the output' do
        placeholder = @parser.compile( %q{#def foo(string)
#echo string.downcase
#end
$foo("HELLO WORLD")}, :class_name => :PlaceholderSpecBeta)
        self.class.class_eval(placeholder)
        self.class::Walrus::WalrusGrammar::PlaceholderSpecBeta.new.fill.should == "hello world"
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

