# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'walrus/grammar'
require 'walrus/grammar/additions/regexp'
require 'walrus/grammar/additions/string'
require 'walrus/grammar/additions/symbol'

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
      
      specify 'should be able to define a simple Node subclass' do
        
        # single element in the Node
        Grammar.subclass('NodeGrammar1') do
          production :MyNodeSubclass, :foo
        end
        
        # two elements in the Node
        Grammar.subclass('NodeGrammar2') do
          production :MyNodeSubclass2, :foo, :bar
        end
        
        # three elements in the Node, one of them skipped
        Grammar.subclass('NodeGrammar3') do
          production :MyNodeSubclass3, :foo, :skip, :bar
        end
        
      end
      
      specify 'should be able to use "build" to wrap up parslets and combintions of parslets' do
      end
      
      specify 'should be able to use "^" as a shorthand for "build"' do
      end
      
      specify 'should complain if an attempt is made to create the same production class twice' do
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

