# Copyright 2007-2010 Wincent Colaiuta. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'pathname'

module Walrus
  # All compiled templates inherit from this class.
  class Document
    def initialize
      @internal_hash = {}
    end

    def set_value key, value
      @internal_hash[key.to_sym] = value
    end

    def get_value key
      @internal_hash[key.to_sym]
    end

    def remove_value key
      @internal_hash.delete key.to_sym
    end

    # Expects a placeholder symbol or String.
    # The parameters are optional.
    def lookup_and_accumulate_placeholder placeholder, *params
      output = lookup_and_return_placeholder placeholder, *params
      accumulate output if output
    end

    def lookup_and_return_placeholder placeholder, *params
      # if exists a method responding to placeholder, call it
      if respond_to? placeholder
        @accumulators << nil                # push new accumulator onto the stack
        output = send placeholder, *params  # call method
        accumulated = @accumulators.pop     # pop last accumulator from the stack
        if accumulated
          return accumulated
        elsif output
          return output
        end
      else  # otherwise, try looking it up in the values hash
        return get_value(placeholder)
      end
    end

    # Supports two calling methods:
    #   - if passed a string it will be appended to the accumulator.
    #   - if not passed a string but given a block will evaluate the block and
    #     append the (string) result to the accumulator.
    def accumulate string = nil
      if @accumulators.last.nil?    # accumulator will be nil if hasn't been used yet
        @accumulators.pop           # replace temporary nil accumulator
        @accumulators.push ""       # with proper string accumulator
      end
      if block_given?
        @accumulators.last << yield.to_s
      elsif not string.nil?
        @accumulators.last << string.to_s
      end
    end

    # Fills (executes) the template body of the receiver and returns the
    # result.
    def fill
      @accumulators = [nil]         # reset accumulators stack
      template_body
      @accumulators.last or ""
    end

    # Prints to standard out the result of filling the receiver. Note that no
    # trailing newline is printed. As a result, if running a template from the
    # terminal be aware that the last line may not be visible or may be partly
    # obscured by the command prompt that is drawn (starting at the first
    # column) after execution completes.
    def run
      printf '%s', fill
      $stdout.flush
    end

    # By default, there is nothing at all in the template body.
    def template_body
    end

    if __FILE__ == $0
      # when run from the command line the default action is to call "run".
      self.new.run
    else
      # if run inside an eval, will return filled content
      self.new.fill
    end
  end # class Document
end # module Walrus
