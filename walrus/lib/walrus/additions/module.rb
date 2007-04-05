# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

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