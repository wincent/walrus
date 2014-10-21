# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    class DefDirective < Directive
      using StringAdditions

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
