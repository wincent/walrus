# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    autoload(:SymbolParslet, 'walrus/grammar/symbol_parslet')
  end
end

class Symbol
  
  require 'walrus/grammar/parslet_combining'
  include Walrus::Grammar::ParsletCombining
  
  # Returns a SymbolParslet based on the receiver.
  # Symbols can be used in Grammars when specifying rules and productions to refer to other rules and productions that have not been defined yet.
  # They can also be used to allow self-references within rules and productions (recursion); for example:
  #   rule :thing & :thing.optional & :other_thing
  # Basically these SymbolParslets allow deferred evaluation of a rule or production (deferred until parsing takes place) rather than being evaluated at the time a rule or production is defined.
  def to_parseable
    Walrus::Grammar::SymbolParslet.new(self)
  end
  
end # class Symbol
