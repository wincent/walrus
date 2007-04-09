# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class Placeholder
      
      def compile(options = {})
        
        # TODO: special case when placeholder is not used as part of literal text; return the value rather than accumulating
        
        if @params == []
          "lookup_and_accumulate_placeholder(#{@name.to_s.to_sym.inspect})\n"
        else
          params      = (@params.kind_of? Array) ? @params : [@params]
          param_list  = params.collect { |param| param.compile }.join(', ')
          "lookup_and_accumulate_placeholder(#{@name.to_s.to_sym.inspect}, #{param_list})\n"
        end
        
      end
      
    end # class Placeholder
    
  end # class WalrusGrammar
end # Walrus

