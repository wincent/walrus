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

require 'walrus'
require 'walrat/additions/string'

module Walrus
  class Template
    attr_reader   :base_text

    # If initialized using a Pathname or File, returns the pathname.
    # Otherwise returns nil.
    attr_reader   :origin

    # Accepts input of class String, Pathname or File
    def initialize input
      raise ArgumentError if input.nil?
      if input.respond_to? :read # should work with Pathname or File
        @base_text  = input.read
        @origin     = input.to_s
      else
        @base_text  = input.to_s
      end
    end

    # The fill method returns a string containing the output produced when
    # executing the compiled template.
    def fill
      @filled ||= instance_eval(compiled)
    end

    def filled
      fill
    end

    # Parses template, returning compiled input (suitable for writing to disk).
    def compile
      @parser   ||= Parser.new
      @compiled ||= @parser.compile(@base_text, :class_name => class_name, :origin => @origin)
    end

    # Returns the compiled text of the receiver
    def compiled
      compile
    end

    # Prints output obtained by running the compiled template.
    def run
      p fill
    end

    def class_name
      if @class_name
        @class_name
      else
        if @origin.nil?
          @class_name = Compiler::DEFAULT_CLASS # "DocumentSubclass"
        else
          @class_name = strip_extensions(@origin).to_class_name
        end
      end
    end

    def strip_extensions(path)
      extension = File.extname(path)
      if extension != ""  # recurse
        strip_extensions File.basename(path, extension) 
      else                # no more extensions
        path
      end
    end
  end # class Template
end # module Walrus
