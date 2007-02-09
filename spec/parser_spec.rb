# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

require 'walrus/parser'

module Walrus
  
  context 'parsing with the parser' do
    
    context_setup do
      @parser = Parser.new()
    end
    
    specify 'should be able to instantiate the parser' do
      @parser.should_not_be_nil
    end
    
    specify 'should be able to parse a plaintext string' do
      
      # a single word
      result = @parser.parse('foo')
      result.should_be_kind_of WalrusGrammar::RawText
      result.lexeme.should == 'foo'
      
      # multiple words
      result = @parser.parse('foo bar')
      result.should_be_kind_of WalrusGrammar::RawText
      result.lexeme.should == 'foo bar'
      
      # multiple lines
      result = @parser.parse("hello\nworld")
      result.should_be_kind_of WalrusGrammar::RawText
      result.lexeme.should == "hello\nworld"
      
    end
    
    specify 'should be able to parse a comment' do
      
      # comment with content
      result = @parser.parse('## hello world')
      result.should_be_kind_of WalrusGrammar::Comment
      result.lexeme.should == ' hello world'
      
      # comment with no content
      result = @parser.parse('##')
      result.should_be_kind_of WalrusGrammar::Comment
      result.lexeme.should == ''
      
    end
    
    specify 'should be able to parse an escape marker' do
      
      # directive marker
      result = @parser.parse('\\#')
      result.should_be_kind_of WalrusGrammar::EscapeSequence
      result.lexeme.should == '#'
      
      # placeholder marker
      result = @parser.parse('\\$')
      result.should_be_kind_of WalrusGrammar::EscapeSequence
      result.lexeme.should == '$'
      
      # escape marker
      result = @parser.parse('\\\\')
      result.should_be_kind_of WalrusGrammar::EscapeSequence
      result.lexeme.should == '\\'
      
      # multiple escape markers
      result = @parser.parse('\\#\\$\\\\')
      result[0].should_be_kind_of WalrusGrammar::EscapeSequence
      result[0].lexeme.should == '#'
      result[1].should_be_kind_of WalrusGrammar::EscapeSequence
      result[1].lexeme.should == '$'
      result[2].should_be_kind_of WalrusGrammar::EscapeSequence
      result[2].lexeme.should == '\\'
      
    end
    
    specify 'should complain on finding an illegal escape marker' do
      
      # invalid character
      lambda { @parser.parse('\\x') }.should_raise Grammar::ParseError
      
      # no character
      lambda { @parser.parse('\\') }.should_raise Grammar::ParseError
      
    end
    
    specify 'should be able to mix comments and plain text' do
      
      # plain text followed by comment
      result = @parser.parse('foobar ## hello world')
      result[0].should_be_kind_of WalrusGrammar::RawText
      result[0].lexeme.should == 'foobar '
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' hello world'
      
      # comment should only extend up until the next newline
      result = @parser.parse("## hello world\nfoobar")
      result[0].should_be_kind_of WalrusGrammar::Comment
      result[0].lexeme.should == ' hello world'
      
    end
    
    specify 'should be able to mix escape markers and plain text' do
      
      # plain text followed by an escape marker
      result = @parser.parse('hello \\#')
      result[0].should_be_kind_of WalrusGrammar::RawText
      result[0].lexeme.should == 'hello '
      result[1].should_be_kind_of WalrusGrammar::EscapeSequence
      result[1].lexeme.should == '#'
      
      # an escape marker followed by plain text
      result = @parser.parse('\\$hello')
      result[0].should_be_kind_of WalrusGrammar::EscapeSequence
      result[0].lexeme.should == '$'
      result[1].should_be_kind_of WalrusGrammar::RawText
      result[1].lexeme.should == 'hello'
      
      # alternation
      result = @parser.parse('hello \\\\ world')
      result[0].should_be_kind_of WalrusGrammar::RawText
      result[0].lexeme.should == 'hello '
      result[1].should_be_kind_of WalrusGrammar::EscapeSequence
      result[1].lexeme.should == '\\'
      result[2].should_be_kind_of WalrusGrammar::RawText
      result[2].lexeme.should == ' world'
      
      # with newlines thrown into the mix
      result = @parser.parse("hello\n\\#")
      result[0].should_be_kind_of WalrusGrammar::RawText
      result[0].lexeme.should == "hello\n"
      result[1].should_be_kind_of WalrusGrammar::EscapeSequence
      result[1].lexeme.should == '#'
      
    end
    
  end
  
end # module Walrus

