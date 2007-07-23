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

require 'walrus'

module Walrus
  class Grammar
    
    class ParsletOmission < ParsletCombination
      
      attr_reader :hash
      
      # Raises an ArgumentError if parseable is nil.
      def initialize(parseable)
        raise ArgumentError if parseable.nil?
        @parseable = parseable
        @hash = @parseable.hash + 46 # fixed offset to avoid unwanted collisions with similar classes
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        substring = StringResult.new
        substring.start = [options[:line_start], options[:column_start]]
        substring.end   = [options[:line_start], options[:column_start]]
        
        # possibly should catch these here as well
        #catch :NotPredicateSuccess do
        #catch :AndPredicateSuccess do
        # one of the fundamental problems is that if a parslet throws such a symbol any info about already skipped material is lost (because the symbols contain nothing)
        # this may be one reason to change these to exceptions...
        catch :ZeroWidthParseSuccess do
          substring = @parseable.memoizing_parse(string, options)
        end
        
        # not enough to just return a ZeroWidthParseSuccess here; that could cause higher levels to stop parsing and in any case there'd be no clean way to embed the scanned substring in the symbol
        raise SkippedSubstringException.new(substring, 
                                            :line_start => options[:line_start],  :column_start => options[:column_start],
                                            :line_end   => substring.line_end,    :column_end   => substring.column_end)
      end
      
      def eql?(other)
        other.instance_of? ParsletOmission and other.parseable.eql? @parseable
      end
      
    protected
      
      # For determining equality.
      attr_reader :parseable
      
    end # class ParsletOmission
  end # class Grammar
end # module Walrus
