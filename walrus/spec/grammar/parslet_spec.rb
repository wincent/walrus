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
# $Id: parslet_spec.rb 166 2007-04-09 15:04:40Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    describe 'using a parslet' do
      
      it 'should complain if sent "parse" message (Parslet is an abstract superclass, "parse" is the responsibility of the subclasses)' do
        lambda { Parslet.new.parse('bar') }.should raise_error(NotImplementedError)
      end
      
    end
    
  end # class Grammar
end # module Walrus
