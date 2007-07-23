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
# $Id: node.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

module Walrus
  class Grammar
    
    # Make subclasses of this for us in Abstract Syntax Trees (ASTs).
    class Node
      
      include Walrus::Grammar::LocationTracking
      
      def to_s
        @string_value
      end
      
      # Dynamically creates a Node descendant.
      # subclass_name should be a Symbol or String containing the name of the subclass to be created.
      # namespace should be the module in which the new subclass should be created; it defaults to Walrus::Grammar.
      # results are optional symbols expected to be parsed when initializing an instance of the subclass. If no optional symbols are provided then a default initializer is created that expects a single parameter and stores a reference to it in an instance variable called "lexeme".
      def self.subclass(subclass_name, namespace = Walrus::Grammar, *results)
        raise ArgumentError if subclass_name.nil?
        
        # create new anonymous class with Node as superclass, assigning it to a constant effectively names the class
        new_class = namespace.const_set(subclass_name.to_s, Class.new(self))
        
        # set up accessors
        for result in results
          new_class.class_eval { attr_reader result }
        end
        
        # set up initializer
        if results.length == 0 # default case, store sole parameter in "lexeme"
          new_class.class_eval { attr_reader :lexeme }
          initialize_body = "def initialize(lexeme)\n"
          initialize_body << "@string_value = lexeme.to_s\n"
          initialize_body << "@lexeme = lexeme\n"
        else
          initialize_body = "def initialize(#{results.collect { |symbol| symbol.to_s}.join(', ')})\n"
          initialize_body << "@string_value = \"\"\n"
          for result in results
            initialize_body << "@#{result.to_s} = #{result.to_s}\n"
            initialize_body << "@string_value << #{result.to_s}.to_s\n"
          end
        end
        initialize_body << "end\n"
        new_class.class_eval initialize_body        
        new_class
      end
      
    end # class Node
    
  end # class Grammar
end # module Walrus
