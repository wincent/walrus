# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require 'walrus'

class Symbol
  
  include Walrus::Grammar::ParsletCombining
  
  # Returns a SymbolParslet based on the receiver.
  # Symbols can be used in Grammars when specifying rules and productions to refer to other rules and productions that have not been defined yet.
  # They can also be used to allow self-references within rules and productions (recursion); for example:
  #   rule :thing & :thing.optional & :other_thing
  # Basically these SymbolParslets allow deferred evaluation of a rule or production (deferred until parsing takes place) rather than being evaluated at the time a rule or production is defined.
  def to_parseable
    Walrus::Grammar::SymbolParslet.new(self)
  end
  
  # Dynamically creates a subclass named after the receiver, with parent class superclass, taking params.
  def build(superclass, *params)    
    
    # first use the continuation trick to find out what grammar (namespace) receiver is being messaged in
    continuation  = nil
    value         = callcc { |c| continuation = c }         
    if value == continuation                                # first time that we're here
      raise Walrus::Grammar::ContinuationWrapperException.new(continuation)  # give higher up a chance to help us
    else # value is the Grammar instance passed to us from higher up using call on the continuation
      grammar = value
    end
    
    # actually create the subclass
    grammar.const_get(superclass.to_s.to_class_name.to_s).subclass(self.to_s.to_class_name.to_s, grammar, *params)
    self
    
  end
  
end # class Symbol
