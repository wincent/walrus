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
# $Id: def_directive.rb 175 2007-04-10 15:00:33Z wincent $

require 'walrus/parser.rb' # make sure that RawText class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class DefDirective
      
      # Returns a string containing the compiled (Ruby) version of receiver.
      def compile(options = {})
        internal = ''
        
        if @params == []
          external = "def #{@identifier.to_s}\n"
        else
          # this will work for the simple case where params are plain identifiers
          params = (@params.kind_of? Array) ? @params : [@params]
          param_list  = params.collect { |param| param.compile }.join(', ')
          external = "def #{@identifier.to_s}(#{param_list})\n"
        end
        
        nested  = nil
        
        if @content.respond_to? :each   : content = @content
        else                              content = [@content]
        end
        
        content.each do |element|
          if element.kind_of? WalrusGrammar::DefDirective # must handle nested def blocks here
            inner, outer = element.compile(options)
            nested = ['', ''] if nested.nil?
            external << inner if inner
            nested[1] << "\n" + outer
          else
            # again, may wish to forget the per-line indenting here if it breaks sensitive directive types
            # (#ruby blocks for example, which might have here documents)
            element.compile(options).each do |lines| # may return a single line or an array of lines
              lines.each { |line| external << '  ' + line }
            end
          end
        end
        
        external << "end\n\n"
        
        if nested
          external << nested[1]
        end
        
        internal = nil if internal == '' # better to return nil than an empty string here (which would get indented needlessly)
        [internal, external]
      end
      
    end # class DefDirective
    
  end # class WalrusGrammar
end # Walrus

