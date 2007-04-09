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
    
    describe 'creating a continuation wrapper exception' do
      
      it 'should complain if initialized with nil' do
        lambda { ContinuationWrapperException.new(nil) }.should raise_error(ArgumentError)
      end
      
    end
    
  end # class Grammar
end # module Walrus
