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

