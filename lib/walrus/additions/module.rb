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

require 'walrus'

class Module
  
private
  
  def attr_accessor_bycopy(*symbols)
    symbols.each { |symbol| attr_bycopy(symbol, true) }
  end
  
  def attr_bycopy(symbol, writeable = false)
    attr_reader symbol
    attr_writer_bycopy(symbol) if writeable
  end
  
  def attr_writer_bycopy(*symbols)
    symbols.each do |symbol|
      self.module_eval %Q{
        def #{symbol.id2name}=(value)
          @#{symbol.id2name} = value.clone
        rescue TypeError
          @#{symbol.id2name} = value
        end
      }
    end
  end
  
end # class Module
