# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrus/grammar'

module Walrus
  class Grammar
    # placeholders may be in long form (${foo}) or short form ($foo)
    # No whitespace allowed between the "$" and the opening "{"
    # No whitespace allowed between the "$" and the placeholder_name
    class Placeholder < Walrat::Node
      def compile options = {}
        if options[:nest_placeholders] == true
          method_name = "lookup_and_return_placeholder"     # placeholder nested inside another placeholder
        else
          method_name = "lookup_and_accumulate_placeholder" # placeholder used in a literal text stream
        end

        if @params == []
          "#{method_name}(#{@name.to_s.to_sym.inspect})\n"
        else
          options = options.clone
          options[:nest_placeholders] = true
          params      = (@params.kind_of? Array) ? @params : [@params]
          param_list  = params.map { |param| param.compile(options) }.join(', ').chomp
          "#{method_name}(#{@name.to_s.to_sym.inspect}, #{param_list})\n"
        end
      end
    end # class Placeholder
  end # class Grammar
end # Walrus
