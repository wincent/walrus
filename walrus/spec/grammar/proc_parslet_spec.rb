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
    
    describe 'using a ProcParslet' do
      
      setup do
        @parslet = lambda do |string, options|
          if string == 'foobar' : string
          else                    raise ParseError.new('expected foobar by got "%s"' + string.to_s)
          end
        end.to_parseable
      end
      
      it 'should raise an ArgumentError if initialized with nil' do
        lambda { ProcParslet.new(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should complain if asked to parse nil' do
        lambda { @parslet.parse(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should raise ParseError if unable to parse' do
        lambda { @parslet.parse('bar') }.should raise_error(ParseError)
      end
      
      it 'should return a parsed value if able to parse' do
        @parslet.parse('foobar').should == 'foobar'
      end
      
      it 'should be able to compare parslets for equality' do
        
        # in practice only parslets created with the exact same Proc instance will be eql because Proc returns different hashes for each
        @parslet.should eql(@parslet.clone)
        @parslet.should eql(@parslet.dup)
        @parslet.should_not eql(lambda { nil }.to_parseable)
        
      end
      
    end
    
  end # class Grammar
end # module Walrus
