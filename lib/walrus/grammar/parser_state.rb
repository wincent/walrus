# Copyright 2007 Wincent Colaiuta
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
        @options                = options.clone
        @options[:line_start]   = 0 if @options[:line_start].nil?
        @options[:column_start] = 0 if @options[:column_start].nil?
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
      
      # Returns the results accumulated so far.
      # Returns an empty array if no results have been accumulated.
      # Returns a single object if only one result has been accumulated.
      # Returns an array of objects if multiple results have been accumulated.
      def results
        if @results.length == 1
          results = @results[0]
        else
          results = @results
        end        
        results.start   = [@original_line_start, @original_column_start]
        results.end     = [@options[:line_end], @options[:column_end]]
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
            
            # bizarre $~ magic going on here that I don't understand
            # the original index method sets $~ but my jindex doesn't (and can't seem to force it to either)
            
            # totally inefficient hack            
            @remainder.index /\r\n|\r|\n/
            
            newline_location    += $~[0].length                         # add the actual characters used to indicate the newline
            @remainder          = @remainder[newline_location..-1]      # strip everything up to and including the newline
          end
          @remainder            = @remainder[@options[:column_end]..-1] # delete up to the current column
        else                                                            # no newlines consumed
          column_delta          = @options[:column_end] - previous_column_end
          if column_delta > 0                                           # there was movement within currentline
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

