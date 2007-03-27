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
    
    context 'using a match data object' do
      
      setup do
        'hello agent' =~ /(\w+)(\s+)(\w+)/
        @match        = MatchDataWrapper.new($~)
      end
      
      specify 'should raise if initialized with nil' do
        lambda { MatchDataWrapper.new(nil) }.should_raise ArgumentError
      end
      
      specify 'stored match data should persist after multiple matches are executed' do
        original      = @match.match_data     # store original value
        'foo'         =~ /foo/                # clobber $~
        @match.match_data.should == original  # confirm that stored value is still intact
      end
      
      specify 'comparisons with Strings should work automatically without having to call the "to_s" method' do
        @match.should         == 'hello agent'  # normal order
        'hello agent'.should  == @match         # reverse order
        @match.should_not     == 'foobar'       # inverse test sense (not equal)
        'foobar'.should_not   == @match
      end
      
    end
    
  end # class Grammar
end # module Walrus
