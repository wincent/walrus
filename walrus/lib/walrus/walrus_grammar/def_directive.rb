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
    
    class DefDirective
      
      # Returns a string containing the compiled (Ruby) version of receiver.
      def compile(options = {})
        internal = ''
        external = "def #{@identifier.to_s}\n"
        
        nested  = nil
        
        
        # for now only handle the parameterless case; handle the other cases later
        #@params.each { |param| compiled << param.compile(options) }
        
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
            # again, may wish to forget the per-line indenting here if it breaks sensitive directive types (#ruby blocks for example, which might have here documents)
            element.compile(options).each { |line| external << '  ' + line }
          end
        end
        
        external << "end\n"
        
        if nested
          external << nested[1]
        end
        
        internal = nil if internal == '' # better to return nil than an empty string here (which would get indented needlessly)
        [internal, external]
      end
      
    end # class DefDirective
    
  end # class WalrusGrammar
end # Walrus

