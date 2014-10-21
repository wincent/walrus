# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus'
require 'pathname'

module Walrus
  # The parser is currently quite slow, although perfectly usable.
  # The quickest route to optimizing it may be to replace it with a C parser
  # inside a Ruby extension, possibly generated using Ragel
  class Parser
    def parse string, options = {}
      Grammar.new.parse string, options
    end

    def compile string, options = {}
      @@compiler ||= Compiler.new
      parsed = []
      catch :AndPredicateSuccess do # catch here because empty files throw
        parsed = parse string, options
      end
      @@compiler.compile parsed, options
    end
  end # class Parser
end # module Walrus
