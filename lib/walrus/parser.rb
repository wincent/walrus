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
        
        rule            :whitespace,                    /\s+/
        rule            :newlines,                      /\r\n|\r|\n/
        rule            :whitespace_or_newlines,        :whitespace | :newlines
        rule            :end_of_input,                  /\z/
        
        rule            :template,                      :template_element.zero_or_more & :end_of_input.and?
        rule            :template_element,              :comment | :directive | :placeholder | :raw_text | :escape_sequence
        
        rule            :raw_text,                      /[^#$\\\]+/
        
        rule            :string_literal,                :single_quoted_string_literal | :doble_quoted_string_literal
        node            :string_literal
        
        rule            :single_quoted_string_literal,  "'".skip & :single_quoted_string_content.optional & "'".skip
        production      :single_quoted_string_literal.build(:string_literal)
        rule            :single_quoted_string_content,  /(\\(?!').|\\'|[^'\\]+)+/
        rule            :double_quoted_string_literal,  '"'.skip & :double_quoted_string_content.optional & '"'.skip
        production      :double_quoted_string_literal.build(:string_literal)
        rule            :double_quoted_string_content,  /(\\(?!").|\\"|[^"\\]+)+/
        
        rule            :identifier,                    /[a-zA-Z_][a-zA-Z0-9_]*/
        
        rule            :ruby_expression,               'not yet implemented'# string literals, numbers, arrays, method calls, etc (basic Ruby subset)
        
        rule            :escape_sequence,               :escape_marker & :escape_character
        rule            :escape_marker,                 '\\'
        rule            :escape_character,              /#\\\$/
        
        rule            :directive,                     '#'.skip & :directive_name & :directive_parameters.optional
        rule            :directive_name,                /[a-zA-Z]+/
        rule            :directive_parameters,          '('.skip & (:directive_parameter >> (',''#'.skip & :directive_parameter).zero_or_more ).optional & ')'.skip
        rule            :directive_parameter,           :placeholder | :ruby_expression
        
        rule            :placeholder,                   '$'.skip & :placeholder_name & :placeholder_parameters.optional
        rule            :placeholder_name,              :identifier
        rule            :placeholder_parameters,        '('.skip & (:placeholder_parameter >> (',' & :placeholder_parameter).zero_or_more).optional & ')'.skip
        rule            :placeholder_parameter,         :placeholder | :ruby_expression
        
        rule            :comment,                       '##'.skip & /.*$/
        production      :comment.build(:node)
        
        
      end
    end
    
  end # class Parser
  
end # module Walrus