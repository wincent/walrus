# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    autoload(:StringEnumerator, 'walrus/grammar/string_enumerator')
    autoload(:StringParslet,    'walrus/grammar/string_parslet')
  end
end

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
  
  # Redefine length in terms of the chars method (necessary because otherwise String reports length in bytes even when working with multi-byte characters).
  # For example, before:
  #   "€".length # 3
  # After:
  #   "€".length # 1
  def length
    self.chars.length
  end
  
  # Returns a character-level enumerator for the receiver.
  def enumerator
    Walrus::Grammar::StringEnumerator.new(self)
  end

end # class String

class String
  
  # Rationale: it's ok to add "&" and "|" methods to string because they don't exist yet (they're not overrides).
  require 'walrus/grammar/parslet_combining'
  include Walrus::Grammar::ParsletCombining
  
  require 'walrus/grammar/omission_data'
  include Walrus::Grammar::OmissionData
  
  # Returns a StringParslet based on the receiver
  def to_parseable
    Walrus::Grammar::StringParslet.new(self)
  end
  
end # class String
