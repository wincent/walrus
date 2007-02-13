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
        
        rule            :whitespace,                        /[ \t\v]+/    # only spaces and tabs, not newlines
        rule            :newline,                           /\r\n|\r|\n/
        rule            :whitespace_or_newlines,            /\s+/
        rule            :end_of_input,                      /\z/
        
        rule            :template,                          :template_element.zero_or_more & :end_of_input.and?
        rule            :template_element,                  :raw_text | :comment | :directive | :placeholder |:escape_sequence
        
        rule            :raw_text,                          /[^\$\\#]+/
        production      :raw_text.build(:node)
        
        rule            :string_literal,                    :single_quoted_string_literal | :double_quoted_string_literal
        node            :string_literal
        
        rule            :single_quoted_string_literal,      "'".skip & :single_quoted_string_content.optional & "'".skip
        production      :single_quoted_string_literal.build(:string_literal)
        rule            :single_quoted_string_content,      /(\\(?!').|\\'|[^'\\]+)+/
        rule            :double_quoted_string_literal,      '"'.skip & :double_quoted_string_content.optional & '"'.skip
        production      :double_quoted_string_literal.build(:string_literal)
        rule            :double_quoted_string_content,      /(\\(?!").|\\"|[^"\\]+)+/
        
        rule            :identifier,                        /[a-zA-Z_][a-zA-Z0-9_]*/
        rule            :constant,                          /[A-Z][a-zA-Z0-9_]*/
        
        rule            :ruby_expression,                   'not yet implemented'# string literals, numbers, arrays, method calls, etc (basic Ruby subset)
        
        rule            :escape_sequence,                   '\\'.skip & /[\$\\#]/
        production      :escape_sequence.build(:node)
        
        # directives like comments should extend to the end of the line
        # but comments should be allowed to appear to the right of a directive
        # the current rules below would allow us to skip newlines between tokens which is bad: we only want to skip whitespace
        
        #rule            :directive,                     /#(?!\r|\n|\s)/.skip & :directive_name & :directive_parameters.optional
        #production      :directive.build(:node, :name, :parameters)
        #skipping        :directive, :whitespace
        #rule            :directive_name,                /block/i | /def/i | /end/i | /extends/i | /import/i | /set/i | /super/i
        #rule            :directive_parameters,          (:directive_parameter >> (','.skip & :directive_parameter).zero_or_more ).optional & :comment.optional
        #rule            :directive_parameter,           :identifier | :string_literal | :placeholder | :ruby_expression
        
        # may have specific rules for some directive types: I think this is the way to go (ie. a C parser wouldn't expect one rule to may onto all language keywords, would it?)
        # eg. #include 'string_literal'
        # or  #extends ClassName
        # or  #set assignment = expression
        # or  #super parameter, list
        # or  #super (parameter, list, with, brackets) // probably don't want brackets as the other directives don't use them
        # or  #block name
        # or  #end (no parameters)
        
        rule            :directive,                     :end_directive | :extends_directive
        node            :directive
        skipping        :directive, :whitespace
        
        # all directives must be followed by a comment, a newline, or the end of the input
        rule            :directive_predicate,           :whitespace.optional.skip & (:comment | :newline | :end_of_input).and?
        
        rule            :end_directive,                 '#end' >> :directive_predicate
        production      :end_directive.build(:directive)
        
        rule            :extends_directive,             '#extends'.skip & :constant >> :directive_predicate
        production      :extends_directive.build(:directive, :class_name)
        
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