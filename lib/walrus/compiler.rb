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
require 'pathname'

module Walrus
  class Compiler
    BODY_INDENT     = ' ' * 8
    OUTSIDE_INDENT  = ' ' * 6
    DEFAULT_CLASS   = 'DocumentSubclass'

    # The public compiler class serves as the interface with the outside world.
    # For thread-safety and concurrency, an inner, private Instance class is
    # spawned in order to perform the actual compilation.
    class Instance
      def initialize options
        @class_name     = (options[:class_name] || DEFAULT_CLASS).to_s
        @template_body  = []  # accumulate body items, joined at end of process
        @outside_body   = []  # accumulate outside-of-body items, joined at end
      end

      def compile_subtree subtree
        template_body   = [] # local variable
        outside_body    = [] # local variable
        subtree = [subtree] unless subtree.respond_to? :each
        options = { :compiler_instance => self } # reset
        subtree.each do |element|
          if element.kind_of? Walrus::Grammar::DefDirective or
             element.kind_of? Walrus::Grammar::IncludeDirective
            # def/block and include directives may return two items
            inner, outer = element.compile options
            outer.each { |line| outside_body << OUTSIDE_INDENT + line } if outer
            inner.each { |line| template_body << BODY_INDENT + line } if inner
          elsif element.instance_of? Walrus::Grammar::ExtendsDirective
            # defines superclass and automatically invoke #super (super) at the
            # head of the template_body
            raise CompileError,
              '#extends may be used only once per template' if @extends_directive
            raise CompileError,
              'illegal #extends (#import already used in this template)' if @import_directive
            @extends_directive = element.compile options
          elsif element.instance_of? Walrus::Grammar::ImportDirective
            # defines superclass with no automatic invocation of #super on the
            # template_body
            raise CompileError,
              '#import may be used only once per template' if @import_directive
            raise CompileError,
              'illegal #import (#extends already used in this template)' if @extends_directive
            @import_directive = element.compile options
          elsif element.kind_of? Walrus::Grammar::Comment and
                element.column_start == 0
            # special case if comment is only thing on input line
            template_body << BODY_INDENT + element.compile(options)
            options[:slurping] = true
            next
          else  # everything else gets added to the template_body
            element.compile(options).each do |line|
              template_body << BODY_INDENT + line # indent by 6 spaces
            end
          end
          options = { :compiler_instance => self } # reset
        end
        [template_body, outside_body]
      end

      def compile(tree)
        inner, outer = compile_subtree tree
        @template_body.concat inner if inner
        @outside_body.concat outer if outer
        if @import_directive
          superclass_name = @import_directive.class_name
          require_line    = "require 'walrus/document'\n" +
                            @import_directive.require_line
        elsif @extends_directive
          superclass_name = @extends_directive.class_name
          require_line    = "require 'walrus/document'\n" +
                            @extends_directive.require_line
          @template_body.unshift BODY_INDENT +
            "super # (invoked automatically due to Extends directive)\n"
        else
          superclass_name = 'Document'
          require_line    = "require 'walrus/document'"
        end

        # additional spacing after #template_body
        @outside_body.unshift("\n")

        <<-RETURN
\#!/usr/bin/env ruby
\# encoding: utf-8
\# Generated by Walrus <http://walrus.wincent.com/>

begin
  require 'rubygems'
rescue LoadError
  # installing Walrus via RubyGems is recommended
  # otherwise Walrus must be installed in the RUBYLIB load path
end

#{require_line}

module Walrus
  class Grammar
    class #{@class_name} < #{superclass_name}
      def template_body
#{@template_body.join.chomp}
      end
#{@outside_body.join.chomp}
      if __FILE__ == $0   # if run from the command line
        new.run           # same as "walrus run __FILE__"
      else                # if read and evaled
        new.fill          # return filled content
      end
    end \# #{@class_name}
  end \# Grammar
end \# Walrus
        RETURN
      end
    end # class Instance

    # Walks the Abstract Syntax Tree, tree, that represents a parsed Walrus
    # template.
    #
    # Returns a String that defines a Document subclass corresponding to the
    # compiled version of the tree.
    def compile tree, options = {}
      Instance.new(options).compile tree
    end
  end # class Compiler
end # module Walrus
