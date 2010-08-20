# Copyright 2007-2010 Wincent Colaiuta
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

require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Walrat::MatchDataWrapper do
  before do
    'hello agent' =~ /(\w+)(\s+)(\w+)/
    @match        = Walrat::MatchDataWrapper.new($~)
  end

  it 'raises if initialized with nil' do
    expect do
      Walrat::MatchDataWrapper.new nil
    end.to raise_error(ArgumentError, /nil data/)
  end

  specify 'stored match data persists after multiple matches are executed' do
    original      = @match.match_data     # store original value
    'foo'         =~ /foo/                # clobber $~
    @match.match_data.should == original  # confirm stored value still intact
  end

  specify 'comparisons with Strings work without having to call "to_s"' do
    @match.should         == 'hello agent'  # normal order
    'hello agent'.should  == @match         # reverse order
    @match.should_not     == 'foobar'       # inverse test sense (not equal)
    'foobar'.should_not   == @match         # reverse order
  end
end
