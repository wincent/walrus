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

require 'walrat/grammar'
require 'walrus'
require 'pathname'

module Walrus
  # The parser is currently quite slow, although perfectly usable.
  # The quickest route to optimizing it may be to replace it with a C parser
  # inside a Ruby extension, possibly generated using Ragel
  class Grammar < Walrat::Grammar
    autoload :AssignmentExpression, 'walrus/grammar/assignment_expression'
    autoload :BlockDirective,       'walrus/grammar/block_directive'
    autoload :Comment,              'walrus/grammar/comment'
    autoload :DefDirective,         'walrus/grammar/def_directive'
    autoload :EchoDirective,        'walrus/grammar/echo_directive'
    autoload :EscapeSequence,       'walrus/grammar/escape_sequence'
    autoload :ImportDirective,      'walrus/grammar/import_directive'
    autoload :IncludeDirective,     'walrus/grammar/include_directive'
    autoload :InstanceVariable,     'walrus/grammar/instance_variable'
    autoload :Literal,              'walrus/grammar/literal'
    autoload :MessageExpression,    'walrus/grammar/message_expression'
    autoload :MultilineComment,     'walrus/grammar/multiline_comment'
    autoload :Placeholder,          'walrus/grammar/placeholder'
    autoload :RawDirective,         'walrus/grammar/raw_directive'
    autoload :RawText,              'walrus/grammar/raw_text'
    autoload :RubyDirective,        'walrus/grammar/ruby_directive'
    autoload :RubyExpression,       'walrus/grammar/ruby_expression'
    autoload :SetDirective,         'walrus/grammar/set_directive'
    autoload :SilentDirective,      'walrus/grammar/silent_directive'
    autoload :SlurpDirective,       'walrus/grammar/slurp_directive'
    autoload :SuperDirective,       'walrus/grammar/super_directive'

    starting_symbol :template
    skipping    :whitespace_or_newlines
    rule        :whitespace_or_newlines,
                /\s+/

    # only spaces and tabs, not newlines
    rule        :whitespace,
                /[ \t]+/
    rule        :newline,
                /(\r\n|\r|\n)/

    # optional whitespace (tabs and spaces only) followed by a
    # backslash/newline (note: this is not escape-aware)
    rule        :line_continuation,
                /[ \t]*\\\n/
    rule        :end_of_input,
                /\z/

    rule        :template,
                :template_element.zero_or_more &
                :end_of_input.and?
    rule        :template_element,
                :raw_text |
                :comment |
                :multiline_comment |
                :directive |
                :placeholder |
                :escape_sequence

    # anything at all other than the three characters which have special
    # meaning in Walrus: $, \ and #
    rule        :raw_text,  /[^\$\\#]+/
    production  :raw_text

    rule        :string_literal,
                :single_quoted_string_literal |
                :double_quoted_string_literal
    skipping    :string_literal, nil
    node        :string_literal, :literal

    rule        :single_quoted_string_literal,
                "'".skip &
                :single_quoted_string_content.optional &
                "'".skip
    node        :single_quoted_string_literal,
                :string_literal
    production  :single_quoted_string_literal
    rule        :single_quoted_string_content,
                /(\\(?!').|\\'|[^'\\]+)+/
    rule        :double_quoted_string_literal,
                '"'.skip &
                :double_quoted_string_content.optional &
                '"'.skip
    node        :double_quoted_string_literal, :string_literal
    production  :double_quoted_string_literal
    rule        :double_quoted_string_content,
                /(\\(?!").|\\"|[^"\\]+)+/

    # TODO: support 1_000_000 syntax for numeric_literals
    rule            :numeric_literal, /\d+\.\d+|\d+(?!\.)/
    node            :numeric_literal, :literal
    production      :numeric_literal

    # this matches both "foo" and "Foo::bar"
    rule            :identifier, /([A-Z][a-zA-Z0-9_]*::)*[a-z_][a-zA-Z0-9_]*/
    node            :identifier, :literal
    production      :identifier

    # this matches both "Foo" and "Foo::Bar"
    rule            :constant, /([A-Z][a-zA-Z0-9_]*::)*[A-Z][a-zA-Z0-9_]*/
    node            :constant, :literal
    production      :constant

    rule            :symbol_literal, /:[a-zA-Z_][a-zA-Z0-9_]*/
    node            :symbol_literal, :literal
    production      :symbol_literal

    rule            :escape_sequence, '\\'.skip & /[\$\\#]/
    production      :escape_sequence

    rule            :comment, '##'.skip & /.*$/
    production      :comment

    # nested multiline comments
    rule            :multiline_comment,
                    '#*'.skip & :comment_content.zero_or_more('') & '*#'.skip
    skipping        :multiline_comment, nil
    production      :multiline_comment, :content

    rule            :comment_content,
                    (:comment & :newline.skip)  |
                    :multiline_comment          |
                    /(                # three possibilities:
                      [^*#]+      |   # - any run of chars other than # or *
                      \#(?!\#|\*) |   # - any # not followed by # or a *
                      \*(?!\#)        # - any * not followed by  #
                     )+               # match the three possibilities repeatedly
                    /x

    rule        :directive, :block_directive    |
                            :def_directive      |
                            :echo_directive     |
                            :extends_directive  |
                            :import_directive   |
                            :include_directive  |
                            :raw_directive      |
                            :ruby_directive     |
                            :set_directive      |
                            :silent_directive   |
                            :slurp_directive    |
                            :super_directive

    node        :directive

    # directives may span multiple lines if and only if the last character on
    # the line is a backslash \
    skipping    :directive, :whitespace | :line_continuation

    # "Directive tags can be closed explicitly with #, or implicitly with the
    # end of the line"
    # http://www.cheetahtemplate.org/docs/users_guide_html_multipage/language.directives.closures.html
    # This means that to follow a directive by a comment on the same line you
    # must explicitly close the directive first (otherwise the grammar would
    # be ambiguous).
    # Note that "skipping" the end_of_input here is harmless as it isn't
    # actually consumed.
    rule        :directive_end,
                ( /#/ | :newline | :end_of_input ).skip

    rule        :block_directive,
                '#block'.skip & :identifier & :def_parameter_list.optional([]) & :directive_end &
                :template_element.zero_or_more([]) &
                '#end'.skip & :directive_end
    production  :block_directive, :identifier, :params, :content

    rule        :def_directive,
                '#def'.skip & :identifier & :def_parameter_list.optional([]) & :directive_end &
                :template_element.zero_or_more([]) &
                '#end'.skip & :directive_end
    production  :def_directive, :identifier, :params, :content

    rule        :echo_directive_long_form,
                '#echo'.skip & :ruby_expression_list & :directive_end
    rule        :echo_directive_short_form,
                '#='.skip & :ruby_expression_list & '#'.skip
    rule        :echo_directive,
                :echo_directive_long_form | :echo_directive_short_form
    production  :echo_directive, :expression

    rule        :import_directive,
                '#import'.skip & :string_literal & :directive_end
    production  :import_directive, :class_name

    rule        :extends_directive,
                '#extends'.skip & :string_literal & :directive_end
    node        :extends_directive, :import_directive
    production  :extends_directive, :class_name

    rule        :include_directive, '#include'.skip & :include_subparslet
    production  :include_directive, :file_name, :subtree

    rule        :include_subparslet, lambda { |string, options|

      # scans a string literal
      parslet   = :string_literal & :directive_end
      file_name = parslet.parse(string, options)

      # if options contains non-nil "origin" then try to construct relative
      # path; otherwise just look in current working directory
      if options[:origin]
        current_location  = Pathname.new(options[:origin]).dirname
        include_target    = current_location + file_name.to_s
      else
        include_target    = Pathname.new file_name.to_s
      end

      # read file into string
      content = include_target.read

      # try to parse string in sub-parser
      sub_options = { :origin => include_target.to_s }
      sub_result  = nil
      catch :AndPredicateSuccess do
        sub_result  = Parser.new.parse(content, sub_options)
      end

      # want to insert a bunch of nodes (a subtree) into the parse tree
      # without advancing the location counters
      sub_tree = Walrat::ArrayResult.new [ file_name, sub_result || [] ]
      sub_tree.start  = file_name.start
      sub_tree.end    = file_name.end
      sub_tree
    }

    rule        :raw_directive,
                '#raw'.skip &
                ((:directive_end & /([^#]+|#(?!end)+)*/ & '#end'.skip & :directive_end) | :here_document)
    production  :raw_directive, :content

    # In order to parse "here documents" we adopt a model similar to the one
    # proposed in this message to the ANTLR interest list:
    # http://www.antlr.org:8080/pipermail/antlr-interest/2005-September/013673.html
    rule        :here_document_marker,  /<<(-?)([a-zA-Z0-9_]+)[ \t]*\n/
    rule        :line,                  /^.*\n/
    rule        :here_document,         lambda { |string, options|

      # for the time-being, not sure if there is much benefit in calling
      # memoizing_parse here
      state     = Walrat::ParserState.new(string, options)
      parsed    = rules[:here_document_marker].parse(state.remainder, state.options)
      state.skipped(parsed)
      marker    = parsed.match_data
      indenting = (marker[1] != '')

      if indenting # whitespace allowed before end marker
        end_marker = /^[ \t]*#{marker[2]}[ \t]*(\n|\z)/.to_parseable # will eat trailing newline
      else         # no whitespace allowed before end marker
        end_marker = /^#{marker[2]}[ \t]*(\n|\z)/.to_parseable         # will eat trailing newline
      end

      while true do
        begin
          skipped = end_marker.parse(state.remainder, state.options)
          state.skipped(skipped)   # found end marker, skip it
          break                    # all done
        rescue Walrat::ParseError  # didn't find end marker yet, consume a line
          parsed = rules[:line].parse(state.remainder, state.options)
          state.parsed(parsed)
        end
      end

      # caller will want a String, not an Array
      results         = state.results
      document        = Walrat::StringResult.new(results.to_s)
      document.start  = results.start
      document.end    = results.end
      document
    }

    rule        :ruby_directive,
                '#ruby'.skip &
                ((:directive_end & /([^#]+|#(?!end)+)*/ & '#end'.skip & :directive_end) | :here_document)
    production  :ruby_directive, :content

    # Unlike a normal Ruby assignement expression, the lvalue of a "#set"
    # directive is an identifier preceded by a dollar sign.
    rule        :set_directive,
                '#set'.skip &
                /\$(?![ \r\n\t])/.skip &
                :placeholder_name &
                '='.skip &
                (:addition_expression | :unary_expression) &
                :directive_end
    production  :set_directive, :placeholder, :expression

    rule        :silent_directive_long_form,
                '#silent'.skip & :ruby_expression_list & :directive_end
    rule        :silent_directive_short_form,
                '# '.skip & :ruby_expression_list & '#'.skip
    rule        :silent_directive,
                :silent_directive_long_form | :silent_directive_short_form
    production  :silent_directive, :expression

    # Accept multiple expressions separated by a semi-colon.
    rule        :ruby_expression_list,
                :ruby_expression >> (';'.skip & :ruby_expression ).zero_or_more

    rule        :slurp_directive,
                '#slurp' & :whitespace.optional.skip & :newline.skip
    production  :slurp_directive

    rule        :super_directive,
                :super_with_parentheses | :super_without_parentheses
    rule        :super_with_parentheses,
                '#super'.skip & :parameter_list.optional & :directive_end
    node        :super_with_parentheses, :super_directive
    production  :super_with_parentheses, :params

    rule        :super_without_parentheses,
                '#super'.skip &
                :parameter_list_without_parentheses &
                :directive_end
    node        :super_without_parentheses, :super_directive
    production  :super_without_parentheses, :params

    # The "def_parameter_list" is a special case of parameter list which
    # disallows interpolated placeholders.
    rule        :def_parameter_list,
                '('.skip & ( :def_parameter >> ( ','.skip & :def_parameter ).zero_or_more ).optional & ')'.skip
    rule        :def_parameter,
                :assignment_expression | :identifier

    rule        :parameter_list,
                '('.skip & ( :parameter >> ( ','.skip & :parameter ).zero_or_more ).optional & ')'.skip
    rule        :parameter_list_without_parentheses,
                :parameter >> ( ','.skip & :parameter ).zero_or_more
    rule        :parameter,
                :placeholder | :ruby_expression

    rule        :placeholder,
                :long_placeholder | :short_placeholder

    rule        :long_placeholder,
                '${'.skip &
                :placeholder_name &
                :placeholder_parameters.optional([]) &
                '}'.skip
    node        :long_placeholder, :placeholder
    production  :long_placeholder, :name, :params

    rule        :short_placeholder,
                /\$(?![ \r\n\t])/.skip &
                :placeholder_name &
                :placeholder_parameters.optional([])
    node        :short_placeholder, :placeholder
    production  :short_placeholder, :name, :params

    rule        :placeholder_name, :identifier
    rule        :placeholder_parameters,
                '('.skip & (:placeholder_parameter >> (','.skip & :placeholder_parameter).zero_or_more).optional & ')'.skip
    rule        :placeholder_parameter, :placeholder | :ruby_expression

    # simplified Ruby subset
    rule        :ruby_expression,
                :assignment_expression  |
                :addition_expression    |
                :unary_expression

    rule        :literal_expression,
                :string_literal   |
                :numeric_literal  |
                :array_literal    |
                :hash_literal     |
                :lvalue           |
                :symbol_literal

    rule        :unary_expression,
                :message_expression | :literal_expression

    rule        :lvalue,
                :class_variable | :instance_variable | :identifier | :constant

    rule        :array_literal,
                '['.skip & ( :ruby_expression >> (','.skip & :ruby_expression ).zero_or_more ).optional & ']'.skip
    node        :array_literal, :ruby_expression
    production  :array_literal, :elements

    rule        :hash_literal,
                '{'.skip & ( :hash_assignment >> (','.skip & :hash_assignment ).zero_or_more ).optional & '}'.skip
    node        :hash_literal, :ruby_expression
    production  :hash_literal, :pairs

    rule        :hash_assignment,
                :unary_expression &
                '=>'.skip &
                (:addition_expression | :unary_expression)
    node        :hash_assignment, :ruby_expression
    production  :hash_assignment, :lvalue, :expression

    rule        :assignment_expression,
                :lvalue & '='.skip & (:addition_expression | :unary_expression)
    production  :assignment_expression, :lvalue, :expression

    # addition is left-associative (left-recursive)
    rule        :addition_expression,
                :addition_expression & '+'.skip & :unary_expression |
                :unary_expression & '+'.skip & :unary_expression
    node        :addition_expression, :ruby_expression
    production  :addition_expression, :left, :right

    # message expressions are left-associative (left-recursive)
    rule        :message_expression,
                :message_expression & '.'.skip & :method_expression |
                :literal_expression & '.'.skip & :method_expression
    production  :message_expression, :target, :message

    rule        :method_expression,
                :method_with_parentheses | :method_without_parentheses
    node        :method_expression, :ruby_expression

    rule        :method_with_parentheses,
                :identifier & :method_parameter_list.optional([])
    node        :method_with_parentheses, :method_expression
    production  :method_with_parentheses, :name, :params
    rule        :method_without_parentheses,
                :identifier & :method_parameter_list_without_parentheses
    node        :method_without_parentheses, :method_expression
    production  :method_without_parentheses, :method_expression, :name, :params

    rule        :method_parameter_list,
                '('.skip & ( :method_parameter >> ( ','.skip & :method_parameter ).zero_or_more ).optional & ')'.skip
    rule        :method_parameter,
                :ruby_expression
    rule        :method_parameter_list_without_parentheses,
                :method_parameter >> ( ','.skip & :method_parameter ).zero_or_more

    rule        :class_variable, '@@'.skip & :identifier
    skipping    :class_variable, nil
    node        :class_variable, :ruby_expression
    production  :class_variable

    rule        :instance_variable, '@'.skip & :identifier
    skipping    :instance_variable, nil
    production  :instance_variable

    # TODO: regexp literal expression

    # Ruby + allowing placeholders for unary expressions
    rule        :extended_ruby_expression,
                :extended_unary_expression | :ruby_expression
    rule        :extended_unary_expression,
                :placeholder | :unary_expression
  end # class Grammar
end # module Walrus
