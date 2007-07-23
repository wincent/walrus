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
    
    describe 'using a match data object' do
      
      before(:each) do
        'hello agent' =~ /(\w+)(\s+)(\w+)/
        @match        = MatchDataWrapper.new($~)
      end
      
      it 'should raise if initialized with nil' do
        lambda { MatchDataWrapper.new(nil) }.should raise_error(ArgumentError)
      end
      
      it 'stored match data should persist after multiple matches are executed' do
        original      = @match.match_data     # store original value
        'foo'         =~ /foo/                # clobber $~
        @match.match_data.should == original  # confirm that stored value is still intact
      end
      
      it 'comparisons with Strings should work automatically without having to call the "to_s" method' do
        @match.should         == 'hello agent'  # normal order
        'hello agent'.should  == @match         # reverse order
        @match.should_not     == 'foobar'       # inverse test sense (not equal)
        'foobar'.should_not   == @match
      end
      
    end
    
  end # class Grammar
end # module Walrus
