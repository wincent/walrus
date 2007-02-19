# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

# Additions to String class for Unicode support.
class String
  
  # Although the Ruby documentation mentions an each_char method it is not implemented in Ruby 1.8.5.
  def each_char(&block)
    enumerator = self.enumerator
    while char = enumerator.next
      yield char
    end
  end
  
  # Returns an array of Unicode characters.
  def chars
    chars = []
    self.each_char { |c| chars << c }
    chars
  end
  
  # Returns a character-level enumerator for the receiver.
  def enumerator
    Walrus::Grammar::StringEnumerator.new(self)
  end

end # class String

class String
  
  # Rationale: it's ok to add "&" and "|" methods to string because they don't exist yet (they're not overrides).
  include Walrus::Grammar::ParsletCombining
  include Walrus::Grammar::OmissionData
  
  # Returns a StringParslet based on the receiver
  def to_parseable
    Walrus::Grammar::StringParslet.new(self)
  end
  
end # class String
