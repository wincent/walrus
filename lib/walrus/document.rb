#!/usr/bin/env ruby
#
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

module Walrus
  
  # All compiled templates inherit from this class.
  class Document
    
    def initialize
      @internal_hash = {}
    end
  
    def set_value(key, value)
      @internal_hash[key] = value
    end
  
    def get_value(key)
      @internal_hash[key]
    end
  
    def remove_value(key)
      @internal_hash.delete(key)
    end
  
    # Expects a placeholder symbol or String.
    # The parameters are optional.
    def lookup_and_accumulate_placeholder(placeholder, *params)
      output = self.lookup_and_return_placeholder(placeholder, *params)
      @accumulators.last << output if output
    end
  
    def lookup_and_return_placeholder(placeholder, *params)
      # if exists a method responding to placeholder, call it
      if self.respond_to? placeholder
        @accumulators << nil                            # push new accumulator onto the stack
        output = self.send(placeholder.to_sym, *params) # call method
        accumulated = @accumulators.pop                 # pop last accumulator from the stack
        if accumulated
          return accumulated
        elsif output
          return output
        end
      else  # otherwise, try looking it up in the values hash
        return self.get_value(placeholder)
      end
    end
  
    def accumulate(string)
      return if string.nil?
      if (@accumulators.last.nil?)  # accumulator will be nil if hasn't been used yet
        @accumulators.pop           # replace temporary nil accumulator
        @accumulators.push("")      # with proper string accumulator
      end
      @accumulators.last << string
    end
    
    # Fills (executes) the template body of the receiver and returns the result.
    def fill
      @accumulators = [nil]         # reset accumulators stack
      self.template_body
      @accumulators.last or ""
    end
    
    # Prints to standard out the result of filling the receiver. Note that no trailing newline is printed. As a result, if running a template from the terminal be aware that the last line may not be visible or may be partly obscured by the command prompt that is drawn (starting at the first column) after execution completes.
    def run
      printf('%s', self.fill)
      $stdout.flush
    end
    
    # By default, there is nothing at all in the template body.
    def template_body
    end
    
    if __FILE__ == $0
      self.new.run      # When run from the command line the default action is to call "run".
    else
      self.new.fill     # in other cases, evaluate 'fill' (if run inside an eval, will return filled content)
    end
    
  end # class Document
end # module Walrus

