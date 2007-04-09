# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require 'walrus'

module Walrus
  class Grammar
    
    # Simple class for maintaining state during a parse operation.
    class ParserState
      
      attr_reader :options
      
      # Returns the remainder (the unparsed portion) of the string. Will return an empty string if already at the end of the string.
      attr_reader :remainder
      
      # Raises an ArgumentError if string is nil.
      def initialize(string, options = {})
        raise ArgumentError if string.nil?
        self.base_string        = string
        @results                = ArrayResult.new                     # for accumulating results
        @remainder              = @base_string.clone
        @scanned                = ''
        @options                = options.clone
        
        # start wherever we last finished (doesn't seem to behave different to the alternative)
        @options[:line_start]   = (@options[:line_end] or @options[:line_start] or 0)
        @options[:column_start] = (@options[:column_end] or @options[:column_start] or 0)
#        @options[:line_start]   = 0 if @options[:line_start].nil?
#        @options[:column_start] = 0 if @options[:column_start].nil?

        @options[:line_end]     = @options[:line_start]               # before parsing begins, end point is equal to start point
        @options[:column_end]   = @options[:column_start]
        @original_line_start    = @options[:line_start]
        @original_column_start  = @options[:column_start]
      end
      
      # The parsed method is used to inform the receiver of a successful parsing event.
      # Note that substring need not actually be a String but it must respond to the following messages:
      #   - "line_end" and "column_end" so that the end position of the receiver can be updated
      # As a convenience returns the remainder.
      # Raises an ArgumentError if substring is nil.
      def parsed(substring)
        raise ArgumentError if substring.nil?
        update_and_return_remainder_for_string(substring, true)
      end
      
      # The skipped method is used to inform the receiver of a successful parsing event where the parsed substring should be consumed but not included in the accumulated results.
      # The substring should respond to "line_end" and "column_end".
      # In all other respects this method behaves exactly like the parsed method.
      def skipped(substring)
        raise ArgumentError if substring.nil?
        update_and_return_remainder_for_string(substring)
      end
      
      # The skipped method is used to inform the receiver of a successful parsing event where the parsed substring should be consumed but not included in the accumulated results and furthermore the parse event should not effect the overall bounds of the parse result. In reality this means that the method is only ever called upon the successful use of a automatic intertoken "skipping" parslet. By definition this method should only be called for intertoken skipping otherwise incorrect results will be produced.
      def auto_skipped(substring)
        raise ArgumentError if substring.nil?
        a, b, c, d = @options[:line_start], @options[:column_start], @options[:line_end], @options[:column_end] # save
        remainder = update_and_return_remainder_for_string(substring)
        @options[:line_start], @options[:column_start], @options[:line_end], @options[:column_end] = a, b, c, d # restore
        remainder
      end
      
      # Returns the results accumulated so far.
      # Returns an empty array if no results have been accumulated.
      # Returns a single object if only one result has been accumulated.
      # Returns an array of objects if multiple results have been accumulated.
      def results
        if @results.length == 1
          results = @results[0]
          results.start         = [@original_line_start, @original_column_start]
          results.end           = [@options[:line_end], @options[:column_end]]
          results.source_text   = @scanned.clone
        else
          results = @results
          results.start         = [@original_line_start, @original_column_start]
          results.end           = [@options[:line_end], @options[:column_end]]
          results.source_text   = @scanned.clone
        end        
        
# so the question is, how could column start be 5 if original column start is 0?
# answer: echo directive started at 0
# skipped to, past the "#echo" 5
# we scanned the expression, starting at 5
# then, when it came time to wrap up the echo directive
# we had only one meaningful element in our results array: the expression
# so when it comes time to return that element for wrapping, it's still correct
# but then we come to the point were we return the EchoDirective
# the corresponding parser state has an @original_column_start of 0
# we get into this method, and the only result in the array is out message expression
# so we extract the expression; we'll return that instead of an array
# and that expression has a start of 5
# which we promptly overwrite below
# and then we wrap it up as the only parameter to the wrapping method for our EchoDirective
# so the problem is that here we really have two pieces of information here
# 1. the coords for the directive as a whole
# 2. the coords for the expression part
# and unfortunately "2" is being overwritten by "1"
# so we need a way to specify two sets of coords instead of 1
# in the case were we return a single result instead of an array
# this means extra methods on the thing returned by results
# to be interpretted by the wrapper
# not sure if it needs to be interpreted elsewhere as well

        results
      end
      
      # Returns the number of results accumulated so far.
      def length
        @results.length
      end
      
      # TODO: possibly implement "undo/rollback" and "reset" methods
      # if I implement "undo" will probbaly do it as a stack
      # will have the option of implementing "redo" as well but I'd only do that if I could think of a use for it
      
    private
      
      def update_and_return_remainder_for_string(input, store = false)
        previous_line_end       = @options[:line_end]                                           # remember old end point
        previous_column_end     = @options[:column_end]                                         # remember old end point
        
        # special case handling for literal String objects
        if input.instance_of? String
          input = StringResult.new(input)
          input.start = [previous_line_end, previous_column_end]
          if (line_count  = input.scan(/\r\n|\r|\n/).length) != 0       # count number of newlines in receiver
            column_end    = input.jlength - input.jrindex(/\r|\n/) - 1  # calculate characters on last line
          else                                                          # no newlines in match
            column_end    = input.jlength + previous_column_end
          end
          input.end   = [previous_line_end + line_count, column_end]
        end
        
        @results << input if (store)
        
        if input.line_end > previous_line_end       # end line has advanced
          @options[:line_end]   = input.line_end
          @options[:column_end] = 0
        end
        
        if input.column_end > @options[:column_end] # end column has advanced
          @options[:column_end] = input.column_end
        end
        
        
        @options[:line_start]   = @options[:line_end]                                           # new start point is old end point
        @options[:column_start] = @options[:column_end]                                         # new start point is old end point
        
        # calculate remainder
        line_delta              = @options[:line_end] - previous_line_end
        if line_delta > 0                                               # have consumed newline(s)
          line_delta.times do                                           # remove them from remainder
            newline_location    = @remainder.jindex /\r\n|\r|\n/        # find the location of the next newline
            newline_location    += $~[0].length                         # add the actual characters used to indicate the newline
            @scanned            << @remainder[0...newline_location]     # record scanned text
            @remainder          = @remainder[newline_location..-1]      # strip everything up to and including the newline
          end
          @scanned              << @remainder[0...@options[:column_end]]
          @remainder            = @remainder[@options[:column_end]..-1] # delete up to the current column
        else                                                            # no newlines consumed
          column_delta          = @options[:column_end] - previous_column_end
          if column_delta > 0                                           # there was movement within currentline
            @scanned            << @remainder[0...column_delta]
            @remainder          = @remainder[column_delta..-1]          # delete up to the current column
          end
        end
        @remainder
      end
      
      def base_string=(string)
        @base_string = (string.clone rescue string)
      end
      
    end # class ParserState
    
  end # class Grammar
end # module Walrus

