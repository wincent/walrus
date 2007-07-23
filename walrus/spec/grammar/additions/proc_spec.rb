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
#
# $Id: proc_spec.rb 166 2007-04-09 15:04:40Z wincent $

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