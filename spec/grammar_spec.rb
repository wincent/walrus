# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'defining a grammar subclass' do
      
      specify 'should be able to create new Grammar subclasses on the fly' do
        
        # first create a new subclass and make sure the returned instance is non-nil
        Grammar.subclass('MyGrammar').should_not_be_nil
        
        # the class constant should now be available for creating new instances 
        MyGrammar.new.should_not_be_nil
      
      end
      
      specify 'should complain if an attempt is made to create the same subclass twice' do
        lambda { Grammar.subclass('FooGrammar') }.should_not_raise
        lambda { Grammar.subclass('FooGrammar') }.should_raise
      end
      
      specify 'should complain if subclass name is nil' do
        lambda { Grammar.subclass(nil) }.should_raise ArgumentError
      end
      
      specify 'should be able to pass a block while defining a new subclass' do
        
        instance = Grammar.subclass('TestGrammar') do
          starting_symbol :foo
        end
        instance.instance_eval("@starting_symbol").should == :foo
        
      end
      
    end
    
    context 'defining rules in a grammar' do
      
      specify '"rules" method should complain if either parameter is nil' do
        lambda { Grammar.subclass('AxeGrammar') { rule nil, 'expression' } }.should_raise ArgumentError
        lambda { Grammar.subclass('BoneGrammar') { rule :my_rule, nil } }.should_raise ArgumentError
        lambda { Grammar.subclass('CatGrammar') { rule nil, nil } }.should_raise ArgumentError
      end
      
      specify '"rules" method should complain if an attempt is made to define a rule a second time' do
        lambda do
          Grammar.subclass('DogGrammar') do
            rule :my_rule, 'foo'
            rule :my_rule, 'bar'
          end
        end.should_raise ArgumentError
      end
      
      specify 'should be able to define rules in the block using the "rule" method' do
        
      end
      
    end
    
    context 'defining productions in a grammar' do
      
      specify '"node" method should complain if new class name is nil' do
        lambda do
          Grammar.subclass('NodeComplainingGrammar') { node nil }
        end.should_raise ArgumentError
      end
      
      specify 'should be able to define a simple Node subclass using the "node" function' do
        
        Grammar.subclass('NodeGrammar1') do
          node      :my_node_subclass
          node      :my_subclass_of_a_subclass, :my_node_subclass
          node      :my_node_class_that_takes_params, :node, :foo, :bar
        end
        
        NodeGrammar1::MyNodeSubclass.to_s.should == 'Walrus::NodeGrammar1::MyNodeSubclass'
        NodeGrammar1::MyNodeSubclass.superclass.should == Node
        NodeGrammar1::MySubclassOfASubclass.to_s.should == 'Walrus::NodeGrammar1::MySubclassOfASubclass'
        NodeGrammar1::MySubclassOfASubclass.superclass.should == NodeGrammar1::MyNodeSubclass
        NodeGrammar1::MyNodeClassThatTakesParams.to_s.should == 'Walrus::NodeGrammar1::MyNodeClassThatTakesParams'
        NodeGrammar1::MyNodeClassThatTakesParams.superclass.should == Node
        node = NodeGrammar1::MyNodeClassThatTakesParams.new('hello', 'world')
        node.foo.should == 'hello'
        node.bar.should == 'world'
        
      end
      
      specify 'should be able to use the "build" method to define production subclasses on the fly' do
        
        Grammar.subclass('HeMeansJavaRuntimeAPIs') do
          rule        :foobar, 'foo' & 'bar'
          production  :foobar.build(:node, :foo, :bar)
        end
        
        # try instantiating the newly created class
        node = HeMeansJavaRuntimeAPIs::Foobar.new('hello', 'world')
        node.class.should == HeMeansJavaRuntimeAPIs::Foobar
        node.foo.should == 'hello'
        node.bar.should == 'world'
        
        # try passing the wrong number of parameters
        lambda { HeMeansJavaRuntimeAPIs::Foobar.new }.should_raise ArgumentError                # no parameters
        lambda { HeMeansJavaRuntimeAPIs::Foobar.new('hi') }.should_raise ArgumentError          # one parameter too few
        lambda { HeMeansJavaRuntimeAPIs::Foobar.new('a', 'b', 'c') }.should_raise ArgumentError # one parameter too many
        
      end
      
      specify 'should complain if an attempt is made to create the same production class twice' do
        lambda do
          Grammar.subclass('HowToGetControlOfJavaAwayFromSun') do
            rule        :foo, 'foo'
            production  :foo
            production  :foo
          end
        end.should_raise ArgumentError
      end
      
      specify 'should complain if an attempt is made to create a production for a rule that does not exist yet' do
        lambda do
          Grammar.subclass('GettingControlOfJavaAwayFromSun') { production :foo }
        end.should_raise ArgumentError
      end
      
    end
    
    context 'parsing using a grammar' do
      
      specify 'should complain if asked to parse a nil string' do
        lambda { Grammar.subclass('BobGrammar').parse(nil) }.should_raise ArgumentError
      end
      
      specify 'should complain if trying to parse without first defining a start symbol' do
        lambda { Grammar.subclass('RoyalGrammar').parse('foo') }.should_raise
      end
      
      specify 'should parse starting with the start symbol' do
        grammar = Grammar.subclass('AliceGrammar') do
          rule            :expr, /\w+/
          starting_symbol :expr
        end
        
        grammar.parse('foo').should == 'foo'
        lambda { grammar.parse('') }.should_raise ParseError
        
      end
      
      specify 'should complain if reference is made to an undefined symbol' do
        grammar = Grammar.subclass('RoyGrammar') { starting_symbol :expr } # :expr is not defined
        lambda { grammar.parse('foo') }.should_raise
      end
      
      specify 'should be able to parse using a simple grammar (one rule)' do
        grammar = Grammar.subclass('SimpleGrammar') do
          starting_symbol :foo
          rule            :foo, 'foo!'
        end
        grammar.parse('foo!').should == 'foo!'
        lambda { grammar.parse('---') }.should_raise ParseError
      end
      
      specify 'should be able to parse using a simple grammar (two rules)' do
        grammar = Grammar.subclass('AlmostAsSimpleGrammar') do
          starting_symbol :foo
          rule            :foo, 'foo!' | :bar
          rule            :bar, /bar/
        end
        grammar.parse('foo!').should == 'foo!'
        grammar.parse('bar').should == 'bar'
        lambda { grammar.parse('---') }.should_raise ParseError
      end
      
      specify 'should be able to parse using a simple grammar (three rules)' do
        
        # a basic version written using intermediary parslets (really two parslets and one rule)
        grammar = Grammar.subclass('MacGrammar') do
          starting_symbol :comment
          
          # parslets
          comment_marker  = '##'
          comment_body    = /.+/
          
          # rules
          rule            :comment,         comment_marker & comment_body.optional
        end
        grammar.parse('## hello!').should == ['##', ' hello!']
        grammar.parse('##').should == '##'
        lambda { grammar.parse('foobar') }.should_raise ParseError
        
        # the same grammar rewritten without intermediary parslets (three rules, no standalone parslets)
        grammar = Grammar.subclass('MacAltGrammar') do
          starting_symbol :comment
          rule            :comment,         :comment_marker & :comment_body.optional
          rule            :comment_marker,  '##'
          rule            :comment_body,    /.+/
        end
        grammar.parse('## hello!').should == ['##', ' hello!']
        grammar.parse('##').should == '##'
        lambda { grammar.parse('foobar') }.should_raise ParseError
      end
      
      specify 'should be able to parse using recursive rules (nested parentheses)' do
        
        # basic example
        grammar = Grammar.subclass('NestedGrammar') do
          starting_symbol :bracket_expression
          rule            :left_bracket,        '('
          rule            :right_bracket,       ')'
          rule            :bracket_content,     (/[^()]+/ | :bracket_expression).zero_or_more
          rule            :bracket_expression,  :left_bracket & :bracket_content.optional & :right_bracket
        end
        grammar.parse('()').should == ['(', ')']
        grammar.parse('(content)').should == ['(', 'content', ')']
        grammar.parse('(content (and more content))').should == ['(', ['content ', ['(', 'and more content', ')']], ')']
        lambda { grammar.parse('(') }.should_raise ParseError
        
        # same example but automatically skipping the delimiting braces for clearer output
        grammar = Grammar.subclass('NestedSkippingGrammar') do
          starting_symbol :bracket_expression
          rule            :bracket_expression,  '('.skip & (/[^()]+/ | :bracket_expression).zero_or_more  & ')'.skip
        end
        grammar.parse('()').should == []
        grammar.parse('(content)').should == 'content'
        grammar.parse('(content (and more content))').should == ['content ', 'and more content']
        grammar.parse('(content (and more content)(and more))').should == ['content ', 'and more content', 'and more']
        grammar.parse('(content (and more content)(and more)(more still))').should == ['content ', 'and more content', 'and more', 'more still']
        grammar.parse('(content (and more content)(and more(more still)))').should == ['content ', 'and more content', ['and more', 'more still']]
        lambda { grammar.parse('(') }.should_raise ParseError
        
        # note that this confusing (possible even misleading) nesting goes away if you use a proper AST
        grammar = Grammar.subclass('NestedBracketsWithAST') do
          starting_symbol :bracket_expression
          rule            :text_expression,     /[^()]+/
          rule            :bracket_expression,  '('.skip & (:text_expression | :bracket_expression).zero_or_more  & ')'.skip
          production      :bracket_expression.build(:node, :children)
        end
        
        # simple tests
        grammar.parse('()').children.should == []
        grammar.parse('(content)').children.to_s.should == 'content'
        
        # nested test: two expressions at the first level, one of them nested
        results = grammar.parse('(content (and more content))')
        results.children[0].should == 'content '
        results.children[1].children.to_s.should == 'and more content'
        
        # nested test: three expressions at first level, two of them nested
        results = grammar.parse('(content (and more content)(and more))')#.should == ['content ', 'and more content', 'and more']        
        results.children[0].should == 'content '        
        results.children[1].children.should == 'and more content'
        results.children[2].children.should == 'and more'
        
        # nested test: four expressions at the first level, three of them nested
        results = grammar.parse('(content (and more content)(and more)(more still))')
        results.children[0].should == 'content '        
        results.children[1].children.should == 'and more content'
        results.children[2].children.should == 'and more'
        results.children[3].children.should == 'more still'
        
        # nested test: three expressions at the first level, one nested and another not only nested but containing another level of nesting
        results = grammar.parse('(content (and more content)(and more(more still)))')
        results.children[0].should == 'content '        
        results.children[1].children.should == 'and more content'
        results.children[2].children[0].should == 'and more'
        results.children[2].children[1].children.should == 'more still'
        
        # bad input case
        lambda { grammar.parse('(') }.should_raise ParseError
        
      end
      
      specify 'should be able to parse using recursive rules (nested comments)' do
        grammar = Grammar.subclass('NestedCommentsGrammar') do
          starting_symbol :comment
          rule            :comment_start,       '/*'
          rule            :comment_end,         '*/'
          rule            :comment_content,     (:comment | /\/+/ | ('*' & '/'.not!) | /[^*\/]+/).zero_or_more
          rule            :comment,             '/*' & :comment_content.optional & '*/'
        end
        grammar.parse('/**/').should == ['/*', '*/']        
        grammar.parse('/*comment*/').should == ['/*', 'comment', '*/']
        grammar.parse('/* comment /* nested */*/').should == ['/*', [' comment ', ['/*', ' nested ', '*/']], '*/']        
        lambda { grammar.parse('/*') }.should_raise ParseError
      end
      
      specify 'should be able to write a grammar that produces an AST for a simple language that supports addition and assignment' do
        
        grammar = Grammar.subclass('SimpleASTLanguage') do
          
          starting_symbol :expression
          
          # terminal tokens
          rule            :identifier,      /[a-zA-Z_][a-zA-Z0-9_]*/
          production      :identifier.build(:node)
          rule            :integer_literal, /[0-9]+/
          production      :integer_literal.build(:node)
          
          # expressions
          rule            :expression,      :assignment_expression | :addition_expression | :identifier | :integer_literal
          node            :expression
          rule            :assignment_expression, :identifier & '='.skip & :expression
          production      :assignment_expression.build(:expression, :target, :value)
          rule            :addition_expression,   (:identifier | :integer_literal) & '+'.skip & :expression
          production      :addition_expression.build(:expression, :summee, :summor)
          
        end
        
        results = grammar.parse('hello')
        results.should_be_kind_of SimpleASTLanguage::Identifier
        results.lexeme.should == 'hello'
        
        results = grammar.parse('1234')
        results.should_be_kind_of SimpleASTLanguage::IntegerLiteral
        results.lexeme.should == '1234'
        
        results = grammar.parse('foo=bar')
        results.should_be_kind_of SimpleASTLanguage::Expression
        results.should_be_kind_of SimpleASTLanguage::AssignmentExpression
        results.target.should_be_kind_of SimpleASTLanguage::Identifier
        results.target.lexeme.should == 'foo'
        results.value.should_be_kind_of SimpleASTLanguage::Identifier
        results.value.lexeme.should == 'bar'
        
        results = grammar.parse('baz+123')
        results.should_be_kind_of SimpleASTLanguage::Expression
        results.should_be_kind_of SimpleASTLanguage::AdditionExpression
        results.summee.should_be_kind_of SimpleASTLanguage::Identifier
        results.summee.lexeme.should == 'baz'
        results.summor.should_be_kind_of SimpleASTLanguage::IntegerLiteral
        results.summor.lexeme.should == '123'
        
        results = grammar.parse('foo=abc+123')
        results.should_be_kind_of SimpleASTLanguage::Expression
        results.should_be_kind_of SimpleASTLanguage::AssignmentExpression
        results.target.should_be_kind_of SimpleASTLanguage::Identifier
        results.target.lexeme.should == 'foo'
        results.value.should_be_kind_of SimpleASTLanguage::AdditionExpression
        results.value.summee.should_be_kind_of SimpleASTLanguage::Identifier
        results.value.summee.lexeme.should == 'abc'
        results.value.summor.should_be_kind_of SimpleASTLanguage::IntegerLiteral
        results.value.summor.lexeme.should == '123'
        
        results = grammar.parse('a+b+2')
        results.should_be_kind_of SimpleASTLanguage::Expression
        results.should_be_kind_of SimpleASTLanguage::AdditionExpression
        results.summee.should_be_kind_of SimpleASTLanguage::Identifier
        results.summee.lexeme.should == 'a'
        results.summor.should_be_kind_of SimpleASTLanguage::AdditionExpression
        results.summor.summee.should_be_kind_of SimpleASTLanguage::Identifier
        results.summor.summee.lexeme.should == 'b'
        results.summor.summor.should_be_kind_of SimpleASTLanguage::IntegerLiteral
        results.summor.summor.lexeme.should == '2'
        
      end
      
      specify 'should be able to write a grammar that complains if all the input is not consumed' do
        grammar = Grammar.subclass('ComplainingGrammar') do
          starting_symbol :translation_unit
          rule            :translation_unit,  :word_list & :end_of_string.and? | :end_of_string
          rule            :end_of_string,     /\z/
          rule            :whitespace,        /\s+/
          rule            :word,              /[a-z]+/
          rule            :word_list,         :word >> (:whitespace.skip & :word).zero_or_more
          
        end
        
        grammar.parse('').should == ''
        grammar.parse('foo').should == 'foo'
        grammar.parse('foo bar').should == ['foo', 'bar']
        lambda { grammar.parse('...') }.should_raise ParseError
        lambda { grammar.parse('foo...') }.should_raise ParseError
        lambda { grammar.parse('foo bar...') }.should_raise ParseError
        
      end
      
      specify 'should be able to define a default parslet for intertoken skipping' do
        
        # simple example
        grammar = Grammar.subclass('SkippingGrammar') do
          starting_symbol :translation_unit
          skipping        :whitespace_and_newlines
          rule            :whitespace_and_newlines, /[\s\n\r]+/ 
          rule            :translation_unit,        :word_list & :end_of_string.and? | :end_of_string
          rule            :end_of_string,           /\z/
          rule            :word_list,               :word.zero_or_more
          rule            :word,                    /[a-z0-9_]+/
        end
        
        # not sure if I can justify the difference in behaviour here compared with the previous grammar
        # if I catch these throws at the grammar level I can return nil
        # but note that the previous grammar returns an empty array, which to_s is just ""
        lambda { grammar.parse('') }.should_throw :AndPredicateSuccess
        
        grammar.parse('foo').should == 'foo'
        grammar.parse('foo bar').should == ['foo', 'bar']       # intervening whitespace
        grammar.parse('foo bar     ').should == ['foo', 'bar']  # trailing whitespace
        grammar.parse('     foo bar').should == ['foo', 'bar']  # leading whitespace
        
        # additional example, this time involving the ">>" pseudo-operator
        grammar = Grammar.subclass('SkippingAndMergingGrammar') do
          starting_symbol :translation_unit
          skipping        :whitespace_and_newlines
          rule            :whitespace_and_newlines, /[\s\n\r]+/ 
          rule            :translation_unit,        :word_list & :end_of_string.and? | :end_of_string
          rule            :end_of_string,           /\z/
          rule            :word_list,               :word >> (','.skip & :word).zero_or_more
          rule            :word,                    /[a-z0-9_]+/
        end
        
        # one word
        grammar.parse('foo').should == 'foo'
        
        # two words
        grammar.parse('foo,bar').should == ['foo', 'bar']         # no whitespace
        grammar.parse('foo, bar').should == ['foo', 'bar']        # whitespace after
        grammar.parse('foo ,bar').should == ['foo', 'bar']        # whitespace before
        grammar.parse('foo , bar').should == ['foo', 'bar']       # whitespace before and after
        grammar.parse('foo , bar     ').should == ['foo', 'bar']  # trailing and embedded whitespace
        grammar.parse('     foo , bar').should == ['foo', 'bar']  # leading and embedded whitespace
        
        # three or four words
        grammar.parse('foo , bar, baz').should == ['foo', 'bar', 'baz']
        grammar.parse(' foo , bar, baz ,bin').should == ['foo', 'bar', 'baz', 'bin']
        
      end
      
      specify 'should complain if trying to set default skipping parslet more than once' do
        lambda do
          Grammar.subclass('SetSkipperTwice') do
            skipping :first   # fine
            skipping :again   # should raise here
          end
        end.should_raise
      end
      
      specify 'should complain if passed nil' do
        lambda do
          Grammar.subclass('PassNilToSkipping') { skipping nil }
        end.should_raise ArgumentError
      end
      
      specify 'should be able to override default skipping parslet on a per-rule basis' do
        
        # the example grammar parses word lists and number lists
        grammar = Grammar.subclass('OverrideDefaultSkippingParslet') do
          starting_symbol :translation_unit
          skipping        :whitespace_and_newlines
          rule            :whitespace_and_newlines, /\s+/       # any whitespace including newlines
          rule            :whitespace,              /[ \t\v]+/  # literally only spaces, tabs, not newlines etc
          rule            :translation_unit,        :component.one_or_more & :end_of_string.and? | :end_of_string
          rule            :end_of_string,           /\z/
          rule            :component,               :word_list | :number_list
          rule            :word_list,               :word.one_or_more
          rule            :word,                    /[a-z]+/
          rule            :number,                  /[0-9]+/
          
          # the interesting bit: we override the skipping rule for number lists
          rule            :number_list,             :number.one_or_more
          skipping        :number_list,             :whitespace # only whitespace, no newlines
        end
        
        # words in word lists can be separated by whitespace or newlines
        grammar.parse('hello world').should ==  ['hello', 'world']
        grammar.parse("hello\nworld").should == ['hello', 'world']
        grammar.parse("hello world\nworld hello").should == ['hello', 'world', 'world', 'hello']
        
        # numbers in number lists may be separated only by whitespace, not newlines
        grammar.parse('123 456').should == ['123', '456']
        grammar.parse("123\n456").should == ['123', '456'] # this succeeds because parser treats them as two separate number lists
        grammar.parse("123 456\n456 123").should == [['123', '456'], ['456', '123']]
        
        # intermixing word lists and number lists
        grammar.parse("bar\n123").should == ['bar', '123']
        grammar.parse("123\n456\nbar").should == ['123', '456', 'bar']
        
        # these were buggy at one point: "123\n456" was getting mashed into "123456" due to misguided use of String#delete! to delete first newline
        grammar.parse("\n123\n456").should == ['123', '456']
        grammar.parse("bar\n123\n456").should == ['bar', '123', '456']
        grammar.parse("baz bar\n123\n456").should == [['baz', 'bar'], '123', '456']
        grammar.parse("hello world\nfoo\n123 456 baz bar\n123\n456").should == [['hello', 'world', 'foo'], ['123', '456'], ['baz', 'bar'], '123', '456']
        
      end
      
      specify 'should complain if trying to override the default for the same rule twice' do
        lambda do
          Grammar.subclass('OverrideSameRuleTwice') do
            rule      :the_rule, 'foo'
            skipping  :the_rule, :the_override  # fine
            skipping  :the_rule, :the_override  # should raise
          end
        end.should_raise ArgumentError
      end
      
      specify "should complain if trying to set an override for a rule that hasn't been defined yet" do
        lambda do
          Grammar.subclass('OverrideUndefinedRule') { skipping :non_existent_rule, :the_override }
        end.should_raise ArgumentError
      end
      
      specify 'use of the "skipping" directive should play nicely with predicates' do
        
        # example 1: word + predicate
        grammar = Grammar.subclass('NicePlayer') do
          starting_symbol :foo
          skipping        :whitespace
          rule            :whitespace,                /[ \t\v]+/
          rule            :foo,                       'hello' & 'world'.and?        
        end
        
        grammar.parse('hello world').should == 'hello'
        grammar.parse('hello      world').should == 'hello'
        grammar.parse('helloworld').should == 'hello'
        lambda { grammar.parse('hello') }.should_raise ParseError
        lambda { grammar.parse('hello buddy') }.should_raise ParseError
        lambda { grammar.parse("hello\nbuddy") }.should_raise ParseError
        
        # example 2: word + predicate + other word
        grammar = Grammar.subclass('NicePlayer2') do
          starting_symbol :foo
          skipping        :whitespace
          rule            :whitespace,                /[ \t\v]+/
          rule            :foo,                       /hel../ & 'world'.and? & /\w+/
        end
        
        grammar.parse('hello world').should == ['hello', 'world']
        grammar.parse('hello      world').should == ['hello', 'world']
        grammar.parse('helloworld').should == ['hello', 'world']
        lambda { grammar.parse('hello') }.should_raise ParseError
        lambda { grammar.parse('hello buddy') }.should_raise ParseError
        lambda { grammar.parse("hello\nbuddy") }.should_raise ParseError
        
      end
      
    end
  end # class Grammar  
end # module Walrus

