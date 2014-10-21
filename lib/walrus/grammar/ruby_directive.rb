# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class RubyDirective < Directive
      using StringAdditions

      # TODO: could make a #rubyecho method that did an "accumulate do" instead
      # of instance_eval
      def compile options = {}
        # possible problem here is that the compiler will indent each line for
        # us, possibly breaking here docs etc
        # seeing as it is going to be indented anyway, I add some additional
        # indenting here for pretty printing purposes
        compiled = "instance_eval do # Ruby directive\n"
        @content.to_s.each { |line| compiled << '  ' + line }
        compiled << "end\n"
      end
    end # class RawDirective
  end # class Grammar
end # Walrus
