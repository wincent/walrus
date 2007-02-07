# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

require 'walrus/grammar'
require 'walrus/grammar/additions/regexp'
require 'walrus/grammar/additions/string'
require 'walrus/grammar/additions/symbol'

module Walrus
  class Grammar
    
    autoload(:Node, 'walrus/grammar/node')
    
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
        grammar.parse('(content)').children.should == 'content'
        
        # nested test: one expression nested at first level
        puts "STARTING FAILING TEST >>>>>>"
        results = grammar.parse('(content (and more content))')
        # diagnostic info:
        #
        # node_class is Walrus::Grammar::BracketExpression
        # will eval: new(result)
        # result is: #<Walrus::Grammar::MatchDataWrapper:0x10ea4b0 @match_data=#<MatchData:0x10ea44c>, @omitted=["(", "", ")"]>
        # wrapped result is #<Walrus::Grammar::BracketExpression:0x10e0230 @children=#<Walrus::Grammar::MatchDataWrapper:0x10ea4b0 @match_data=#<MatchData:0x10ea44c>, @omitted=["(", "", ")"]>>
        #
        # i think the problem is that in wrapping the lower-level (nested) BracketExpression our higher-level parslet combination dies
        # witness the stack trace:
        #
        # NoMethodError in 'parsing using a grammar should be able to parse using recursive rules (nested parentheses)'
        # undefined method `join' for nil:NilClass
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parser_state.rb:48:in `parsed'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_repetition.rb:30:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_repetition.rb:26:in `catch'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_repetition.rb:26:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:58:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:56:in `catch'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:56:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:55:in `catch'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:55:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:54:in `catch'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:54:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:53:in `catch'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:53:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:52:in `each'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar/parslet_sequence.rb:52:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/lib/walrus/grammar.rb:40:in `parse'
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/spec/grammar_spec.rb:254:
        # /Users/wincent/trabajo/unversioned/walrus/svn-files/trunk/spec/grammar_spec.rb:137:
        #
        # the problem is that our ParserState class gets handed the AST-wrapper, but it's a Node subclass that doesn't know how to 
        # respond to the "to_s" message
        # 
        # needed action:
        #    Node subclasses must respond to_s
        #    they must also respond to "omitted" (whatever is returned by omitted must also respond "to_s")
        # may be able to handle this at the level of Node
        # iterate over instance variables and send to_s and omitted.to_s to each, accumulating results
        # 
        # alternative approach:
        # let the "wrap" method handle this
        # it's up to "wrap" to send "to_s" and "omitted.to_s" to the result(s)
        # store them back in the object using ivar accessor methods
        #
        puts "THIS LINE NEVER EXECUTED"
        results.children[0].should == 'content '
        results.children[1].children.should == 'and more content'
        
        
        grammar.parse('(content (and more content)(and more))')#.should == ['content ', 'and more content', 'and more']
        grammar.parse('(content (and more content)(and more)(more still))')#.should == ['content ', 'and more content', 'and more', 'more still']
        grammar.parse('(content (and more content)(and more(more still)))')#.should == ['content ', 'and more content', ['and more', 'more still']]
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
      
    end
  end # class Grammar  
end # module Walrus

