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
#
# $Id: symbol.rb 191 2007-04-26 15:26:26Z wincent $

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
    # Ruby 1.9/2.0 will not support continuations, so may need to come up with an alternative
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
