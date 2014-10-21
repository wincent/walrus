# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus'

module Walrus
  class Grammar
    class CompileError < Exception
      # take an optional hash (for packing extra info into exception?)
      # position in AST/source file
      # line number, column number
      # filename
      def initialize(message, info = {})
        super message
      end
    end # class CompileError
  end # class Grammar
end # module Walrus
