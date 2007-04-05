# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'using a symbol parslet' do
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { SymbolParslet.new(nil) }.should raise_error(ArgumentError)
      end
      
      specify 'should be able to compare symbol parslets for equality' do
        :foo.to_parseable.should eql(:foo.to_parseable)           # equal
        :foo.to_parseable.should_not eql(:bar.to_parseable)       # different
        :foo.to_parseable.should_not eql(:Foo.to_parseable)       # differing only in case
        :foo.to_parseable.should_not eql(/foo/)                   # totally different classes
      end
      
    end
    
  end # class Grammar
end # module Walrus
