# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  
  autoload(:Grammar, 'walrus/grammar')
  
  class Parser
    
    # In order to parse "here documents" we adopt a model similar to the one proposed in this message to the ANTLR interest list:
    # http://www.antlr.org:8080/pipermail/antlr-interest/2005-September/013673.html
    class HereDocumentSubParser
      
      def initialize
        @marker_parslet = /\A<<(-?)([a-zA-Z0-9_]+)[ \t\v]*$/.to_parseable
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        state   = ParserState.new
        parsed  = @marker_parslet.parse(string)
        marker  = parsed.match_data
        indents = (marker[0].nil?) ? false : true
        
        if idents # whitespace allowed before end marker
          /^[ \t\v]*#{marker[1]}$\n/
        else  # no whitespace allowed before end marker
          /^#{marker[1]}$\n/
        end
        
      end
      
    end
    
    def parse(string)
      @@grammar.parse(string)
    end
    
    def initialize
      @@grammar ||= Grammar.subclass('WalrusGrammar') do
        
        starting_symbol :template
        
        skipping        :whitespace_or_newlines
        
        rule            :whitespace_or_newlines,        /\s+/
        
        # only spaces and tabs, not newlines
        rule            :whitespace,                    /[ \t\v]+/
        rule            :newline,                       /(\r\n|\r|\n)/
        
        # optional whitespace (tabs and spaces only) followed by a backslash/newline (note: this is not escape-aware)
        rule            :line_continuation,             /[ \t\v]*\\\n/
        rule            :end_of_input,                  /\z/
        
        rule            :template,                      :template_element.zero_or_more & :end_of_input.and?
        rule            :template_element,              :raw_text | :comment | :multiline_comment | :directive | :placeholder |:escape_sequence
        
        # anything at all other than the three characters which have special meaning in Walrus: $, \ and #
        rule            :raw_text,                      /[^\$\\#]+/
        production      :raw_text.build(:node)
        
        rule            :string_literal,                :single_quoted_string_literal | :double_quoted_string_literal
        node            :string_literal
        
        rule            :single_quoted_string_literal,  "'".skip & :single_quoted_string_content.optional & "'".skip
        production      :single_quoted_string_literal.build(:string_literal)
        rule            :single_quoted_string_content,  /(\\(?!').|\\'|[^'\\]+)+/
        rule            :double_quoted_string_literal,  '"'.skip & :double_quoted_string_content.optional & '"'.skip
        production      :double_quoted_string_literal.build(:string_literal)
        rule            :double_quoted_string_content,  /(\\(?!").|\\"|[^"\\]+)+/
        
        rule            :numeric_literal,               /\d+\.\d+|\d(?!\.)/
        production      :numeric_literal.build(:node)
        rule            :identifier,                    /[a-z_][a-zA-Z0-9_]*/
        production      :identifier.build(:node)
        rule            :constant,                      /[A-Z][a-zA-Z0-9_]*/
        production      :constant.build(:node)
        
        rule            :escape_sequence,               '\\'.skip & /[\$\\#]/
        production      :escape_sequence.build(:node)
        
        rule            :comment,                       '##'.skip & /.*$/
        production      :comment.build(:node)
        
        # nested multiline comments
        rule            :multiline_comment,             '#*'.skip & :comment_content.optional & '*#'.skip
        skipping        :multiline_comment, nil
        production      :multiline_comment.build(:comment, :content)
        
        # human-language version of the regex: "any run of characters other than # or *, any # not followed by another # or a *, or any * not followed by a #"
        rule            :comment_content,               ( (:comment & :newline) | :multiline_comment | :whitespace_or_newlines | /([^*#]+|#(?!#|\*)|\*(?!#))+/ ).one_or_more
        # might be nice to have a "compress" or "to_string" or "raw" operator here; we're not really interested in the internal structure of the comment
        # basically, given a result, walk the structure (if any) calling "to_s" and "omitted" and reconstructing the original text? (or calling a "base_text" method)
                
        rule            :directive,                     :extends_directive | :import_directive | :include_directive | :raw_directive | :set_directive | :slurp_directive |
                                                        :super_directive
        
        node            :directive
        
        # directives may span multiple lines if and only if the last character on the line is a backslash \
        skipping        :directive,                     :whitespace | :line_continuation
        
        # "Directive tags can be closed explicitly with #, or implicitly with the end of the line"
        # http://www.cheetahtemplate.org/docs/users_guide_html_multipage/language.directives.closures.html
        # Note that "skipping" the end_of_input here is harmless as it isn't actually consumed
        rule            :directive_end,                 ( /#/ | :newline | :end_of_input ).skip
        
        # TODO: make block directive keep consuming content until it hits an #end directive, store this in a content attribute
        rule            :block_directive,               '#block' & :identifier & :def_parameter_list.optional & :directive_end
        
        rule            :def_directive,                 '#def' & :identifier & :def_parameter_list.optional & :directive_end
        
        # "The #echo directive is used to echo the output from expressions that can't be written as simple $placeholders."
        # http://www.cheetahtemplate.org/docs/users_guide_html_multipage/output.echo.html
        rule            :echo_directive,                '#echo'.skip & :ruby_expression & :directive_end
        
        rule            :extends_directive,             '#extends'.skip & :constant & :directive_end
        production      :extends_directive.build(:directive, :class_name)
        
        rule            :import_directive,              '#import'.skip & :constant & :directive_end
        production      :import_directive.build(:directive, :class_name)
        
        rule            :include_directive,             '#include'.skip & :string_literal & :directive_end
        production      :include_directive.build(:directive, :file_name)
        
        # "Any section of a template definition that is inside a #raw ... #end raw tag pair will be printed verbatim without any parsing of $placeholders or other directives."
        # http://www.cheetahtemplate.org/docs/users_guide_html_multipage/output.raw.html
        # Unlike Cheetah, Walrus uses a bare "#end" marker and not an "#end raw" to mark the end of the raw block.
        # I suspect that the regular expression used here is probably very slow; if it proves to be cripplingly slow I may need to write another kind of parslet, similar to a RegexpParslet but which uses a different implementation under the hood (see http://swtch.com/~rsc/regexp/regexp1.html).
        rule            :raw_directive,                 '#raw'.skip & :directive_end & /.*?(?=#end)/m & '#end'.skip & :directive_end
        production      :raw_directive.build(:directive, :content)
        
        # May be able to allow the presence of a literal #end within a raw block by using a "here doc"-style delimiter:
        #
        # #raw <<END_MARKER
        #     content goes here
        # END_MARKER
        #
        # or, if the end marker is to be indented:
        #
        # #raw <<-END_MARKER
        #     content
        #      END_MARKER
        #
        # This may require some extensions to the parser generator (the ability to create a StringParslet during parsing and assign that somewhere, using it to detect the end of the block).
#        rule            :raw_here_document,             '#raw'.skip & /<<[A-Z_]+/.store(:here_doc).skip & retrieve(:here_doc) 
#        rule            :raw_here_document,             '#raw'.skip & /<<[A-Z_]+/.and? & @here_document_subparser
        
        rule            :set_directive,                 '#set'.skip & :assignment_expression & :directive_end
        production      :set_directive.build(:directive, :assignment)
        
        # "#silent is the opposite of #echo. It executes an expression but discards the output."
        # http://www.cheetahtemplate.org/docs/users_guide_html_multipage/output.silent.html
        rule            :silent_directive,              '#silent'.skip & :ruby_expression & :directive_end
        production      :silent_directive.build(:directive, :expression)
        
        # "The #slurp directive eats up the trailing newline on the line it appears in, joining the following line onto the current line."
        # http://www.cheetahtemplate.org/docs/users_guide_html_multipage/output.slurp.html
        # The "slurp" directive must be the last thing on the line (not followed by a comment or directive end marker)
        rule            :slurp_directive,               '#slurp' & :whitespace.optional.skip & :newline.skip
        production      :slurp_directive.build(:directive)
        
        rule            :super_directive,               :super_with_parentheses | :super_without_parentheses
        node            :super_directive
        rule            :super_with_parentheses,        '#super'.skip & :parameter_list.optional & :directive_end
        production      :super_with_parentheses.build(:super_directive, :params)
        rule            :super_without_parentheses,     '#super'.skip & :parameter_list_without_parentheses & :directive_end
        production      :super_without_parentheses.build(:super_directive, :params)
        
        # The "def_parameter_list" is a special case of parameter list which disallows interpolated placeholders.
        rule            :def_parameter_list,            '('.skip & ( :def_parameter >> ( ','.skip & :def_parameter ).zero_or_more ).optional & ')'.skip
        rule            :def_parameter,                 :identifier | :assignment_expression
        
        rule            :parameter_list,                '('.skip & ( :parameter >> ( ','.skip & :parameter ).zero_or_more ).optional & ')'.skip
        rule            :parameter_list_without_parentheses,  :parameter >> ( ','.skip & :parameter ).zero_or_more
        rule            :parameter,                     :placeholder | :ruby_expression
        
        # placeholders may be in long form (${foo}) or short form ($foo)
        rule            :placeholder,                   :long_placeholder | :short_placeholder
        rule            :long_placeholder,              '$'.skip & '{'.skip & :placeholder_name & :placeholder_parameters.optional & '}'.skip
        rule            :short_placeholder,             '$'.skip & :placeholder_name & :placeholder_parameters.optional
        rule            :placeholder_name,              :identifier
        rule            :placeholder_parameters,        '('.skip & (:placeholder_parameter >> (','.skip & :placeholder_parameter).zero_or_more).optional & ')'.skip
        rule            :placeholder_parameter,         :placeholder | :ruby_expression
        
        # simplified Ruby subset 
        rule            :ruby_expression,               :unary_expression | :assignment_expression | :addition_expression
        rule            :literal_expression,            :string_literal | :numeric_literal | :array_literal | :hash_literal | :identifier
        rule            :unary_expression,              :literal_expression | :message_expression
        rule            :array_literal,                 '['.skip & ( :ruby_expression >> (','.skip & :ruby_expression ).zero_or_more ).optional & ']'.skip
        rule            :hash_literal,                  '{'.skip & ( :hash_assignment >> (','.skip & :hash_assignment ).zero_or_more ).optional & '}'.skip
        rule            :hash_assignment,               :unary_expression & '=>'.skip & (:unary_expression | :addition_expression)
        rule            :assignment_expression,         :identifier & '='.skip & (:addition_expression | :unary_expression)
        rule            :addition_expression,           :unary_expression & '+'.skip & (:addition_expression | :unary_expression)
        rule            :message_expression,            :literal_expression & '.'.skip & :method_expression
        rule            :method_expression,             :identifier & :method_parameter_list.optional 
        
        # for simplicity, require parenthesis around parameter lists
        rule            :method_parameter_list,         '('.skip & ( :method_parameter >> ( ',' & :method_parameter ).zero_or_more ).optional & ')'.skip
        rule            :method_parameter,              :ruby_expression
        
      end
      
    end
    
  end # class Parser
  
end # module Walrus