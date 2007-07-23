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

module Walrus
  class Grammar
    
    describe 'using a symbol parslet' do
      
      it 'should raise an ArgumentError if initialized with nil' do
        lambda { SymbolParslet.new(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should be able to compare symbol parslets for equality' do
        :foo.to_parseable.should eql(:foo.to_parseable)           # equal
        :foo.to_parseable.should_not eql(:bar.to_parseable)       # different
        :foo.to_parseable.should_not eql(:Foo.to_parseable)       # differing only in case
        :foo.to_parseable.should_not eql(/foo/)                   # totally different classes
      end
      
    end
    
  end # class Grammar
end # module Walrus
