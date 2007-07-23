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
    
    class ParsletMerge < ParsletSequence
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        state                         = ParserState.new(string, options)
        last_caught                   = nil # keep track of the last kind of throw to be caught
        @components.each do |parseable|
          catch :ProcessNextComponent do
            catch :NotPredicateSuccess do
              catch :AndPredicateSuccess do
                catch :ZeroWidthParseSuccess do
                  begin
                    parsed = parseable.memoizing_parse(state.remainder, state.options)
                    if parsed.respond_to? :each
                      parsed.each { |element| state.parsed(element) }
                    else
                      state.parsed(parsed)
                    end
                  rescue SkippedSubstringException => e
                    state.skipped(e)
                  # rescue ParseError => e # failed, will try to skip; save original error in case skipping fails                                        
                  #   if options.has_key?(:skipping_override) : skipping_parslet = options[:skipping_override]
                  #   elsif options.has_key?(:skipping)       : skipping_parslet = options[:skipping]
                  #   else                                      skipping_parslet = nil
                  #   end
                  #   raise e if skipping_parslet.nil?        # no skipper defined, raise original error
                  #   begin
                  #     parsed = skipping_parslet.memoizing_parse(state.remainder, state.options) # guard against self references (possible infinite recursion) here?
                  #     state.skipped(parsed)
                  #     redo              # skipping succeeded, try to redo
                  #   rescue ParseError
                  #     raise e           # skipping didn't help either, raise original error
                  #   end
                  end
                  last_caught = nil
                  throw :ProcessNextComponent # can't use "next" here because it will only break out of innermost "do"
                end
                last_caught = :ZeroWidthParseSuccess
                throw :ProcessNextComponent
              end
              last_caught = :AndPredicateSuccess
              throw :ProcessNextComponent
            end
            last_caught = :NotPredicateSuccess
          end
        end
        
        if state.results.respond_to? :empty? and state.results.empty? and
         throw last_caught
        else
          state.results
        end
        
      end
      
      def eql?(other)
        return false if not other.instance_of? ParsletMerge
        other_components = other.components
        return false if @components.length != other_components.length
        for i in 0..(@components.length - 1)
          return false unless @components[i].eql? other_components[i]
        end
        true
      end
      
    private
      
      def hash_offset
        53
      end
      
    end # class ParsletMerge
  end # class Grammar
end # module Walrus

