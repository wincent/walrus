# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  class Grammar
    
    class ParsletCombination
      
      require 'walrus/grammar/parslet_combining'
      include Walrus::Grammar::ParsletCombining
      
      require 'walrus/grammar/memoizing'
      include Walrus::Grammar::Memoizing
      
      def to_parseable
        self
      end
      
    end # module ParsletCombination
    
  end # class Grammar
end # module Walrus
