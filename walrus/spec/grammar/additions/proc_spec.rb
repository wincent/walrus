# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    describe 'work with Proc instances' do
      
      it 'should respond to "to_parseable", "parse" and "memoizing_parse"' do
        proc = lambda { |string, options| 'foo' }.to_parseable
        proc.parse('bar').should == 'foo'
        proc.memoizing_parse('bar').should == 'foo'
      end
      
    end
    
  end # class Grammar
end # module Walrus