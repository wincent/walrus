# Copyright 2007 Wincent Colaiuta
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
