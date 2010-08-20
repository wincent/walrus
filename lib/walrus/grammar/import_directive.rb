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

require 'walrus/grammar.rb'
require 'walrat/additions/string.rb'
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
            info.require_line = "require File.join(File.dirname(__FILE__), '#{base.to_s}').to_s"
          else
            # desired template is in a relative directory
            info.require_line = "require File.join(File.dirname(__FILE__), '#{dir.to_s}', '#{base.to_s}').to_s"
          end
        end
        info
      end
    end # class ImportDirective
  end # class Grammar
end # Walrus
