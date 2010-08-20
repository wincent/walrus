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

describe Walrus::Grammar::SilentDirective do
  context 'in a document' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'produces no output' do
      eval @parser.compile "#silent 'foo'",
        :class_name => :SilentDirectiveSpecAlpha
      Walrus::Grammar::SilentDirectiveSpecAlpha.new.fill.should == ''
    end
  end
end
