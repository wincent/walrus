# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class Comment < Walrat::Node
      def compile options = {}
        '# Comment:' + @lexeme.to_s + "\n"
      end
    end
  end # class Grammar
end # Walrus
