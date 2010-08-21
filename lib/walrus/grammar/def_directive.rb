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

module Walrus
  class Grammar
    class DefDirective < Directive
      # Returns a string containing the compiled (Ruby) version of receiver.
      def compile options = {}
        internal = ''

        if @params == []
          external = "def #{@identifier.to_s}\n"
        else
          # this will work for the simple case where params are plain identifiers
          params = (@params.kind_of? Array) ? @params : [@params]
          param_list  = params.map { |param| param.compile }.join(', ')
          external = "def #{@identifier.to_s}(#{param_list})\n"
        end

        nested  = nil

        if @content.respond_to? :each
          content = @content
        else
          content = [@content]
        end

        content.each do |element|
          if element.kind_of? Walrus::Grammar::DefDirective
            # must handle nested def blocks here
            inner, outer = element.compile(options)
            nested = ['', ''] if nested.nil?
            external << inner if inner
            nested[1] << "\n" + outer
          else
            # again, may wish to forget the per-line indenting here if it
            # breaks sensitive directive types
            # (#ruby blocks for example, which might have here documents)
            element.compile(options).each do |lines|
              # may return a single line or an array of lines
              lines.each { |line| external << '  ' + line }
            end
          end
        end

        external << "end\n\n"

        if nested
          external << nested[1]
        end

        # better to return nil than an empty string here (which would get
        # indented needlessly)
        internal = nil if internal == ''
        [internal, external]
      end
    end # class DefDirective
  end # class Grammar
end # Walrus
