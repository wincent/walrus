# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

# Additions to String class for Unicode support.
class String
  
  # Returns an array of Unicode characters.
  def chars
    scan(/./m)
  end
  
  alias old_range []
  
  # multi-byte friendly [] implementation
  def [](range, other = Walrus::NoParameterMarker.instance)
    if other == Walrus::NoParameterMarker.instance
      if range.kind_of? Range
        chars[range].join
      else
        old_range range
      end
    else
      old_range range, other
    end
  end
  
  # multi-byte friendly rindex implementation
  def jrindex(search, other = Walrus::NoParameterMarker.instance) 
    
    # first let original implementation do the work
    if other == Walrus::NoParameterMarker.instance
      idx = rindex search
    else
      idx = rindex search, other
    end
    
    # idx is now a number of bytes so must convert to character count    
    index_to_jindex(idx)
    
  end
  
  # multi-byte friendly index implementation
  def jindex(search, other = Walrus::NoParameterMarker.instance)
    
    # first let original implementation do the work
    if other == Walrus::NoParameterMarker.instance
      idx = index search
    else
      idx = index search, other
    end
    
    # idx is now a number of bytes so must convert to character count
    index_to_jindex(idx)
    
  end
  
  # Returns a character-level enumerator for the receiver.
  def enumerator
    Walrus::Grammar::StringEnumerator.new(self)
  end
  
private
  
  def index_to_jindex(idx)
    idx ? unpack('C*')[0...idx].pack('C*').jlength : idx
  end
  
end # class String

class String
  
  include Walrus::Grammar::ParsletCombining   # Rationale: it's ok to add "&" and "|" methods to string because they don't exist yet (they're not overrides).
  
  # Returns a StringParslet based on the receiver
  def to_parseable
    Walrus::Grammar::StringParslet.new(self)
  end
  
end # class String
