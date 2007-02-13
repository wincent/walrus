# Copyright 2007 Wincent Colaiuta
# $Id$

module Walrus
  
  autoload(:Grammar, 'walrus/grammar')
  
  class Parser
    
    def parse(string)
      @@grammar.parse(string)
    end
    
    def initialize
      @@grammar ||= Grammar.subclass('WalrusGrammar') do
        
        starting_symbol :template
        
        skipping        :whitespace_or_newlines
        
        rule            :whitespace,                    /[ \t\v]+/    # only spaces and tabs, not newlines
        rule            :newline,                       /\r\n|\r|\n/
        rule            :whitespace_or_newlines,        /\s+/
        rule            :end_of_input,                  /\z/
        
        rule            :template,                      :template_element.zero_or_more & :end_of_input.and?
        rule            :template_element,              :raw_text | :comment | :directive | :placeholder |:escape_sequence
        
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
        rule            :identifier,                    /[a-z_][a-zA-Z0-9_]*/
        rule            :constant,                      /[A-Z][a-zA-Z0-9_]*/
        
        rule            :escape_sequence,               '\\'.skip & /[\$\\#]/
        production      :escape_sequence.build(:node)
        
        rule            :comment,                       '##'.skip & /.*$/
        production      :comment.build(:node)
        
        
        rule            :directive,                     :end_directive | :extends_directive | :import_directive | :include_directive
        # | :super_directive | :set_directive
        
        node            :directive
        skipping        :directive, :whitespace
        
        # all directives must be followed by a comment, a newline, or the end of the input
        rule            :directive_predicate,           :whitespace.optional.skip & (:comment | :newline | :end_of_input).and?
        
        rule            :block_directive,               '#block' & :identifier & :def_parameter_list.optional >> :directive_predicate
        
        rule            :def_directive,                 '#def' & :identifier & :def_parameter_list.optional >> :directive_predicate
        
        rule            :end_directive,                 '#end' >> :directive_predicate
        production      :end_directive.build(:directive)
        
        rule            :extends_directive,             '#extends'.skip & :constant >> :directive_predicate
        production      :extends_directive.build(:directive, :class_name)
        
        rule            :import_directive,              '#import'.skip & :constant >> :directive_predicate
        production      :import_directive.build(:directive, :class_name)
        
        rule            :include_directive,             '#include'.skip & :string_literal >> :directive_predicate
        production      :include_directive.build(:directive, :file_name)
        
        rule            :def_parameter_list,            '('.skip & ( :def_parameter >> ( ','.skip & :def_parameter ).zero_or_more ).optional & ')'.skip
        rule            :def_parameter,                 :identifier | :assignment_expression
        
        rule            :placeholder,                   '$'.skip & :placeholder_name & :placeholder_parameters.optional
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
        rule            :assignment_expression,         :identifier & '='.skip & (:unary_expression | :addition_expression)
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