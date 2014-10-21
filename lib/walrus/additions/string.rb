# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

module Walrus
  module StringAdditions
    refine String do
      # Returns a copy of the receiver with occurrences of \ replaced with \\, and
      # occurrences of ' replaced with \'
      def to_source_string
        gsub(/[\\']/, '\\\\\&')
      end

      def each &block
        each_line &block
      end
    end
  end # module StringAdditions
end # module Walrus
