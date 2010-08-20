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

describe Walrus::Grammar::MessageExpression do
  describe 'calling source_text on a message expression inside an echo directive' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should return the text of the expression only' do
      directive = @parser.parse '#echo string.downcase'
      directive.column_start.should == 0
      directive.expression.target.column_start.should == 6
      directive.expression.message.column_start.should == 13

      pending 'proper boundary detection requires massive changes to the algorithm'
      directive.expression.column_start.should == 6                 # currently returns: 0
      directive.expression.source_text.should == 'string.downcase'  # currently returns: #echo string.downcase

    end
  end
end
