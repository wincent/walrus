# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar/def_directive'

module Walrus
  class Grammar
    class BlockDirective < DefDirective
      # Returns a string containing the compiled (Ruby) version of receiver.
      def compile options = {}
        inner, outer = super
        inner = '' if inner.nil?
        inner << "lookup_and_accumulate_placeholder(#{@identifier.to_s.to_sym.inspect})\n"
        [inner, outer]
      end
    end # class BlockDirective
  end # class Grammar
end # Walrus
