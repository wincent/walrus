# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    class ParsletCombination
      
      include Walrus::Grammar::ParsletCombining
      include Walrus::Grammar::Memoizing
      
      def to_parseable
        self
      end
      
    end # module ParsletCombination
    
  end # class Grammar
end # module Walrus
