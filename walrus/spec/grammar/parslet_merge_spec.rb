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
    
    context 'using a Parslet Merge' do
      
      specify 'should be able to compare for equality' do
        ParsletMerge.new('foo', 'bar').should_eql ParsletMerge.new('foo', 'bar')
        ParsletMerge.new('foo', 'bar').should_not_eql ParsletOmission.new('foo') # wrong class
      end
      
      specify 'ParsletMerge and ParsletSequence hashs should not match even if created using the same parseable instances' do
        parseable1 = 'foo'.to_parseable
        parseable2 = 'bar'.to_parseable
        p1 = ParsletMerge.new(parseable1, parseable2)
        p2 = ParsletSequence.new(parseable1, parseable2)
        p1.hash.should_not == p2.hash
        p1.should_not_eql p2
      end
      
    end
    
  end # class Grammar
end # module Walrus
