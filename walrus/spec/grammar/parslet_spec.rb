# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
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
