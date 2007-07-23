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
# $Id: slurp_directive.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus/parser.rb' # make sure that the class has been defined prior to extending it

module Walrus
  class WalrusGrammar
    
    class SlurpDirective
      
      # The slurp directive produces no meaningful output; but we leave a comment in the compiled template so that the location of the directive is visible in the source.
      def compile(options = {})
        "# Slurp directive\n"
      end
      
    end # class SlurpDirective
    
  end # class WalrusGrammar
end # Walrus

