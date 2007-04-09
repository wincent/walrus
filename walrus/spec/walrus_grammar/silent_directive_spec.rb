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
    
    describe 'producing a Document containing a SilentDirective' do
      
      setup do
        @parser = Parser.new
      end
      
      it 'should produce no output' do
        
        # simple example
        compiled = @parser.compile("#silent 'foo'", :class_name => :SilentDirectiveSpecAlpha)
        self.class.class_eval(compiled).should == ''
        
      end
      
    end
    
  end # class WalrusGrammar
end # module Walrus

