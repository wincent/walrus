# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: placeholder.rb 177 2007-04-10 16:10:41Z wincent $

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class Placeholder
      
      def compile(options = {})
        
        if options[:nest_placeholders] == true
          method_name = "lookup_and_return_placeholder"     # placeholder nested inside another placeholder
        else
          method_name = "lookup_and_accumulate_placeholder" # placeholder used in a literal text stream
        end
        
        if @params == []
          "#{method_name}(#{@name.to_s.to_sym.inspect})\n"
        else
          options = options.clone
          options[:nest_placeholders] = true
          params      = (@params.kind_of? Array) ? @params : [@params]
          param_list  = params.collect { |param| param.compile(options) }.join(', ').chomp
          "#{method_name}(#{@name.to_s.to_sym.inspect}, #{param_list})\n"
        end
        
      end
      
    end # class Placeholder
    
  end # class WalrusGrammar
end # Walrus

