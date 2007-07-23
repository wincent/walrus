#!/usr/bin/env ruby
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

require 'rubygems'
require 'spec'
require File.join(File.dirname(__FILE__), '..', 'walruscloth')

describe 'using WalrusCloth' do
  
  it 'should be able to create an unordered list' do
    # => "<ul>\n\t<li>hello</li>\n\t</ul>"
    WalrusCloth.new('* hello').to_html.should == RedCloth.new('* hello').to_html
  end
  
  it 'should be able to create an ordered list' do
    # => "<ol>\n\t<li>hello</li>\n\t</ol>"
    WalrusCloth.new('` hello').to_html.should == RedCloth.new('# hello').to_html
  end
  
  it 'should be able to nest lists' do
    # => "<ol>\n\t<li>hello\n\t<ul>\n\t<li>world</li>\n\t</ol></li>\n\t</ul>"
    WalrusCloth.new("` hello\n`* world").to_html.should == RedCloth.new("# hello\n#* world").to_html
  end
  
end

