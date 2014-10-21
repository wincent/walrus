# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'
require 'ostruct'

module Walrus
  class Grammar
    class ImportDirective < Directive
      # Returns an OpenStruct encapsulating information about the receiver for use by the compiler
      def compile options = {}
        info = OpenStruct.new
        path = Pathname.new @class_name.lexeme.to_s

        if path.absolute?
          # it will work just fine as it is
          info.class_name   = path.basename.to_s.to_class_name
          info.require_line = "require '#{path.to_s}'"
        else
          dir, base       = path.split
          info.class_name = base.to_s.to_class_name
          if dir.to_s == '.'
            # desired template is in the same directory
            info.require_line = "require File.expand_path('#{base}', File.dirname(__FILE__))"
          else
            # desired template is in a relative directory
            info.require_line = "require File.expand_path('#{dir}/#{base}', File.dirname(__FILE__))"
          end
        end
        info
      end
    end # class ImportDirective
  end # class Grammar
end # Walrus
