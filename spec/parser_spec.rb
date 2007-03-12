# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

module Walrus
  
  context 'parsing raw text, escape markers and comments' do
    
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
      
      # multi-line comment (empty)
      result = @parser.parse('#**#')
      result.should_be_kind_of WalrusGrammar::Comment
      result.should_be_kind_of WalrusGrammar::MultilineComment
      result.content.should == ''
      
      # multi-line comment (with content)
      result = @parser.parse('#* hello world *#')
      result.should_be_kind_of WalrusGrammar::MultilineComment
      result.content.should == ' hello world '
      
      # multi-line comment (spanning multiple lines)
      result = @parser.parse("#* hello\nworld *#")
      result.should_be_kind_of WalrusGrammar::MultilineComment
      result.content.should == " hello\nworld "
      
      # multi-line comment (with nested comment)
      result = @parser.parse('#* hello #*world*# *#')
      result.should_be_kind_of WalrusGrammar::MultilineComment
      result.content[0].should == ' hello '
      result.content[1].should_be_kind_of WalrusGrammar::MultilineComment
      result.content[1].content.should == 'world'
      result.content[2].should == ' '
      
      # multi-line comment (with nested comment, spanning multiple lines)
      result = @parser.parse("#* hello\n#* world\n... *# *#")
      result.should_be_kind_of WalrusGrammar::MultilineComment
      result.content[0].should == " hello\n"
      result.content[1].should_be_kind_of WalrusGrammar::MultilineComment
      result.content[1].content.should == " world\n... "
      result.content[2].should == ' '
      
      # multi-line comment (with nested single-line comment)
      result = @parser.parse("#* ##hello\n*#")
      result.should_be_kind_of WalrusGrammar::MultilineComment
      result.content[0].should == ' '
      result.content[1].should_be_kind_of WalrusGrammar::Comment
      result.content[1].lexeme.should == 'hello' # here the newline gets eaten
      
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
    
  context 'parsing directives' do
    
    context_setup do
      @parser = Parser.new()
    end
    
    specify 'should complain on encountering an unknown or invalid directive name' do
      lambda { @parser.parse('#glindenburgen') }.should_raise Grammar::ParseError
      lambda { @parser.parse('#') }.should_raise Grammar::ParseError
    end
    
    specify 'should complain if there is whitespace between the directive marker (#) and the directive name' do
      lambda { @parser.parse('# extends "other_template"') }.should_raise Grammar::ParseError
    end
    
    specify 'should be able to parse a directive that takes a single parameter' do
      result = @parser.parse('#extends "other_template"')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::ExtendsDirective
      result.class_name.lexeme.should == 'other_template'
    end
    
    specify 'should be able to follow a directive by a comment on the same line, only if the directive has an explicit termination marker' do
      
      # no intervening whitespace ("extends" directive, takes one parameter)
      result = @parser.parse('#extends "other_template"### comment')
      result[0].should_be_kind_of WalrusGrammar::ExtendsDirective
      result[0].class_name.lexeme.should == 'other_template'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#extends "other_template"## comment') }.should_raise Grammar::ParseError
      
      # intervening whitespace (between parameter and trailing comment)
      result = @parser.parse('#extends "other_template"           ### comment')
      result[0].should_be_kind_of WalrusGrammar::ExtendsDirective
      result[0].class_name.lexeme.should == 'other_template'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#extends "other_template"           ## comment') }.should_raise Grammar::ParseError
      
      # intervening whitespace (between directive and parameter)
      result = @parser.parse('#extends          "other_template"           ### comment')
      result[0].should_be_kind_of WalrusGrammar::ExtendsDirective
      result[0].class_name.lexeme.should == 'other_template'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#extends          "other_template"           ## comment') }.should_raise Grammar::ParseError
      
    end
    
    specify 'should be able to span directives across lines by using a line continuation backslash' do
      
      # basic case
      result = @parser.parse("#extends \\\n'other_template'")
      result.should_be_kind_of WalrusGrammar::ExtendsDirective
      result.class_name.lexeme.should == 'other_template'
      
      # should fail if backslash is not the last character on the line
      lambda { @parser.parse("#extends \\ \n'other_template'") }.should_raise Grammar::ParseError
      
    end

    specify 'should be able to parse an "import" directive' do
      
      # followed by a newline
      result = @parser.parse("#import 'other_template'\nhello")
      result[0].should_be_kind_of WalrusGrammar::ImportDirective
      result[0].class_name.lexeme.should == 'other_template'
      result[1].should_be_kind_of WalrusGrammar::RawText
      result[1].lexeme.should == 'hello' # newline gets eaten
      
      # followed by whitespace
      result = @parser.parse('#import "other_template"     ')
      result.should_be_kind_of WalrusGrammar::ImportDirective
      result.class_name.lexeme.should == 'other_template'
      
      # followed by the end of the input
      result = @parser.parse('#import "other_template"')
      result.should_be_kind_of WalrusGrammar::ImportDirective
      result.class_name.lexeme.should == 'other_template'
      
      # comment with no intervening whitespace
      result = @parser.parse('#import "other_template"### comment')
      result[0].should_be_kind_of WalrusGrammar::ImportDirective
      result[0].class_name.lexeme.should == 'other_template'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#import "other_template"## comment') }.should_raise Grammar::ParseError
      
      # intervening whitespace (between parameter and trailing comment)
      result = @parser.parse('#import "other_template"           ### comment')
      result[0].should_be_kind_of WalrusGrammar::ImportDirective
      result[0].class_name.lexeme.should == 'other_template'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#import "other_template"           ## comment') }.should_raise Grammar::ParseError
      
      # intervening whitespace (between directive and parameter)
      result = @parser.parse('#import          "other_template"           ### comment')
      result[0].should_be_kind_of WalrusGrammar::ImportDirective
      result[0].class_name.lexeme.should == 'other_template'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#import          "other_template"           ## comment') }.should_raise Grammar::ParseError
      
    end
    
    specify 'should be able to parse an "include" directive' do
      
      # basic case: double-quoted file name
      result = @parser.parse('#include "file/to/include"')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::IncludeDirective
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.file_name.lexeme.should == 'file/to/include'
      
      # basic case: single-quoted file name
      result = @parser.parse("#include 'file/to/include'")
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::IncludeDirective
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.file_name.lexeme.should == 'file/to/include'
      
    end
    
    specify 'should be able to parse single quoted string literals' do
      
      # string literals have no special meaning when part of raw text
      result = @parser.parse("'hello'")
      result.should_be_kind_of WalrusGrammar::RawText
      result.lexeme.should == "'hello'"
      
      # empty string
      result = @parser.parse("#include ''")
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.file_name.lexeme.to_s.should == '' # actually just returns []; I might need to add a "flatten" or "to_string" method to my Grammar specification system
      
      # with escaped single quotes inside
      result = @parser.parse("#include 'hello \\'world\\''")
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.file_name.lexeme.should == "hello \\'world\\'"
      
      # with other escapes inside
      result = @parser.parse("#include 'hello\\nworld'")
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello\nworld'
      
      # with double quotes inside
      result = @parser.parse("#include 'hello \"world\"'")
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello "world"'
      
      # with Walrus comments inside (ignored)
      result = @parser.parse("#include 'hello ##world'")
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello ##world'
      
      # with Walrus placeholders inside (no interpolation)
      result = @parser.parse("#include 'hello $world'")
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello $world'
      
      # with Walrus directives inside (no interpolation)
      result = @parser.parse("#include 'hello #end'")
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello #end'
      
    end
    
    specify 'should be able to parse double quoted string literals' do
      
      # string literals have no special meaning when part of raw text
      result = @parser.parse('"hello"')
      result.should_be_kind_of WalrusGrammar::RawText
      result.lexeme.should == '"hello"'
      
      # empty string
      result = @parser.parse('#include ""')
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.file_name.lexeme.to_s.should == '' # actually just returns []; I might need to add a "flatten" or "to_string" method to my Grammar specification system
      
      # with escaped double quotes inside
      result = @parser.parse('#include "hello \\"world\\""')
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello \\"world\\"'
      
      # with other escapes inside
      result = @parser.parse('#include "hello\\nworld"')
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello\\nworld'
      
      # with single quotes inside
      result = @parser.parse('#include "hello \'world\'"')
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.file_name.lexeme.should == "hello 'world'"
      
      # with Walrus comments inside (ignored)
      result = @parser.parse('#include "hello ##world"')
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello ##world'
      
      # with Walrus placeholders inside (no interpolation)
      result = @parser.parse('#include "hello $world"')
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello $world'
      
      # with Walrus directives inside (no interpolation)
      result = @parser.parse('#include "hello #end"')
      result.file_name.should_be_kind_of WalrusGrammar::StringLiteral
      result.file_name.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.file_name.lexeme.should == 'hello #end'
      
    end
    
    # will use the #silent directive here because it's an easy way to make the parser look for a ruby expression
    specify 'should be able to parse basic Ruby expressions' do
      
      # a numeric literal
      result = @parser.parse('#silent 1')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.lexeme.should == '1'
      
      # a single-quoted string literal
      result = @parser.parse("#silent 'foo'")
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::SingleQuotedStringLiteral
      result.expression.lexeme.should == 'foo'
      
      # a double-quoted string literal
      result = @parser.parse('#silent "foo"')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.expression.lexeme.should == 'foo'
      
      # an identifier
      result = @parser.parse('#silent foo')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::Identifier
      result.expression.lexeme.should == 'foo'
      
      result = @parser.parse('#silent foo_bar')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::Identifier
      result.expression.lexeme.should == 'foo_bar'
      
      # a constant
      result = @parser.parse('#silent Foo')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::Constant
      result.expression.lexeme.should == 'Foo'
      
      result = @parser.parse('#silent FooBar')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::Constant
      result.expression.lexeme.should == 'FooBar'
      
      # a symbol
      result = @parser.parse('#silent :foo')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::SymbolLiteral
      result.expression.lexeme.should == ':foo'
      
      result = @parser.parse('#silent :Foo')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::SymbolLiteral
      result.expression.lexeme.should == ':Foo'
      
      # an array literal
      result = @parser.parse('#silent [1]')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::RubyExpression
      result.expression.should_be_kind_of WalrusGrammar::ArrayLiteral
      result.expression.elements.should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.elements.lexeme.should == '1'
      
      result = @parser.parse('#silent [1, 2, 3]')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::RubyExpression
      result.expression.should_be_kind_of WalrusGrammar::ArrayLiteral
      result.expression.elements.should_be_kind_of Array
      result.expression.elements[0].should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.elements[0].lexeme.should == '1'
      result.expression.elements[1].should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.elements[1].lexeme.should == '2'
      result.expression.elements[2].should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.elements[2].lexeme.should == '3'
      
      # a hash literal
      result = @parser.parse('#silent { :foo => "bar" }')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::RubyExpression
      result.expression.should_be_kind_of WalrusGrammar::HashLiteral
      result.expression.pairs.should_be_kind_of WalrusGrammar::RubyExpression
      result.expression.pairs.should_be_kind_of WalrusGrammar::HashAssignment
      result.expression.pairs.lvalue.should_be_kind_of WalrusGrammar::SymbolLiteral
      result.expression.pairs.lvalue.lexeme.should == ':foo'
      result.expression.pairs.expression.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.expression.pairs.expression.lexeme.should == 'bar'
      
      result = @parser.parse('#silent { :foo => "bar", :baz => "xyz" }')
      result.expression.should_be_kind_of WalrusGrammar::HashLiteral
      result.expression.pairs.should_be_kind_of Array
      result.expression.pairs[0].should_be_kind_of WalrusGrammar::HashAssignment
      result.expression.pairs[0].lvalue.should_be_kind_of WalrusGrammar::SymbolLiteral
      result.expression.pairs[0].lvalue.lexeme.should == ':foo'
      result.expression.pairs[0].expression.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.expression.pairs[0].expression.lexeme.should == 'bar'
      result.expression.pairs[1].should_be_kind_of WalrusGrammar::HashAssignment
      result.expression.pairs[1].lvalue.should_be_kind_of WalrusGrammar::SymbolLiteral
      result.expression.pairs[1].lvalue.lexeme.should == ':baz'
      result.expression.pairs[1].expression.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.expression.pairs[1].expression.lexeme.should == 'xyz'
      
      # an addition expression
      result = @parser.parse('#silent 1 + 2')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::RubyExpression
      result.expression.should_be_kind_of WalrusGrammar::AdditionExpression
      result.expression.left.should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.left.lexeme.should == '1'
      result.expression.right.should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.right.lexeme.should == '2'
      
      # an assignment expression
      result = @parser.parse('#silent foo = 1')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::RubyExpression
      result.expression.should_be_kind_of WalrusGrammar::AssignmentExpression
      result.expression.lvalue.should_be_kind_of WalrusGrammar::Identifier
      result.expression.lvalue.lexeme.should == 'foo'
      result.expression.expression.should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.expression.lexeme.should == '1'
      
      # a method invocation
      result = @parser.parse('#silent foo.delete')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::RubyExpression
      result.expression.should_be_kind_of WalrusGrammar::MessageExpression
      
      result = @parser.parse('#silent foo.delete()')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::MessageExpression
      result.expression.target.should_be_kind_of WalrusGrammar::Identifier
      result.expression.target.lexeme.should == 'foo'
      result.expression.message.should_be_kind_of WalrusGrammar::RubyExpression
      result.expression.message.should_be_kind_of WalrusGrammar::MethodExpression
      result.expression.message.name.should_be_kind_of WalrusGrammar::Identifier
      result.expression.message.name.lexeme.should == 'delete'
      result.expression.message.params.should_be_kind_of Array
      result.expression.message.params.should == []
      
      result = @parser.parse('#silent foo.delete(1)')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::MessageExpression
      result.expression.target.should_be_kind_of WalrusGrammar::Identifier
      result.expression.target.lexeme.should == 'foo'
      result.expression.message.should_be_kind_of WalrusGrammar::MethodExpression
      result.expression.message.name.should_be_kind_of WalrusGrammar::Identifier
      result.expression.message.name.lexeme.should == 'delete'
      result.expression.message.params.should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.message.params.lexeme.should == '1'
      
      result = @parser.parse('#silent foo.delete(bar, baz)')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::MessageExpression
      result.expression.target.should_be_kind_of WalrusGrammar::Identifier
      result.expression.target.lexeme.should == 'foo'
      result.expression.message.should_be_kind_of WalrusGrammar::MethodExpression
      result.expression.message.name.should_be_kind_of WalrusGrammar::Identifier
      result.expression.message.name.lexeme.should == 'delete'
      result.expression.message.params.should_be_kind_of Array
      result.expression.message.params[0].should_be_kind_of WalrusGrammar::Identifier
      result.expression.message.params[0].lexeme.should == 'bar'
      result.expression.message.params[1].should_be_kind_of WalrusGrammar::Identifier
      result.expression.message.params[1].lexeme.should == 'baz'
      
      # chained method invocation
      result = @parser.parse('#silent foo.bar.baz')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::MessageExpression
      result.expression.target.should_be_kind_of WalrusGrammar::Identifier
      result.expression.target.lexeme.should == 'foo'
      
      # TODO: fix associativity in the above example:
      # it is currently right-associative:  foo.(bar.baz)
      # but is should be left-associative:  (foo.bar).baz
      # I suspect the same problem is most likely true for the addition expression below
      # (technically parsed as left associative, addition is associative anyway so it doesn't matter)
      
      # chained method invocation with arguments
      result = @parser.parse('#silent foo.bar(1).baz')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::MessageExpression
      
      result = @parser.parse('#silent foo.bar.baz(2)')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::MessageExpression
            
      result = @parser.parse('#silent foo.bar(1).baz(2)')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::MessageExpression
      
      # nested arrays
      result = @parser.parse('#silent [1, 2, [foo, bar]]')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::ArrayLiteral
      
      # nesting in a hash
      result = @parser.parse('#silent { :foo => [1, 2] }')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::HashLiteral
      
      # multiple addition expressions
      result = @parser.parse('#silent 1 + 2 + 3')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::AdditionExpression
      
      # addition and assignment
      result = @parser.parse('#silent foo = bar + 1')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::AssignmentExpression
      
    end
    
    specify 'should be able go from AST representation of a Ruby expression to an evaluable string form' do
      
      result = @parser.parse('#silent 1 + 2 + 3')
      
      # given that ruby expressions might be able to contain placeholders, i am not sure if a simple "reverse to original string" method will be enough...
      
    end
    
    specify 'should be able to parse the "block" directive' do
      
      # simple case: no parameters, no content
      result = @parser.parse("#block foo\n#end")
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should == []
      
      # pathologically short case
      result = @parser.parse('#block foo##end')
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should == []
      
      # some content
      result = @parser.parse('#block foo#hello#end')
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should_be_kind_of WalrusGrammar::RawText
      result.content.lexeme.should == 'hello'
      
      result = @parser.parse("#block foo\nhello\n#end")
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should_be_kind_of WalrusGrammar::RawText
      result.content.lexeme.should == "hello\n"
      
      # empty params list
      result = @parser.parse("#block foo()\n#end")
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should == []
      
      # one param
      result = @parser.parse("#block foo(bar)\n#end")
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params.should_be_kind_of WalrusGrammar::Identifier
      result.params.lexeme.should == 'bar'
      result.content.should == []
      
      # one param with blockault value
      result = @parser.parse("#block foo(bar = 1)\n#end")
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params.should_be_kind_of WalrusGrammar::AssignmentExpression
      result.params.lvalue.should_be_kind_of WalrusGrammar::Identifier
      result.params.lvalue.lexeme.should == 'bar'
      result.params.expression.should_be_kind_of WalrusGrammar::NumericLiteral
      result.params.expression.lexeme.should == '1'
      result.content.should == []
      
      result = @parser.parse("#block foo(bar = nil)\n#end")
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params.should_be_kind_of WalrusGrammar::AssignmentExpression
      result.params.lvalue.should_be_kind_of WalrusGrammar::Identifier
      result.params.lvalue.lexeme.should == 'bar'
      result.params.expression.should_be_kind_of WalrusGrammar::Identifier
      result.params.expression.lexeme.should == 'nil'
      result.content.should == []
      
      # two params
      result = @parser.parse("#block foo(bar, baz)\n#end")
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'foo'
      result.params[0].should_be_kind_of WalrusGrammar::Identifier
      result.params[0].lexeme.should == 'bar'
      result.params[1].should_be_kind_of WalrusGrammar::Identifier
      result.params[1].lexeme.should == 'baz'
      result.content.should == []
      
      # nested block block
      result = @parser.parse(%Q{#block outer
hello
#block inner
world
#end
...
#end})
      result.should_be_kind_of WalrusGrammar::BlockDirective
      result.identifier.to_s.should == 'outer'
      result.params.should == []
      result.content[0].should_be_kind_of WalrusGrammar::RawText
      result.content[0].lexeme.should == "hello\n"
      result.content[1].should_be_kind_of WalrusGrammar::BlockDirective
      result.content[1].identifier.to_s.should == 'inner'
      result.content[1].params.should == []
      result.content[1].content.should_be_kind_of WalrusGrammar::RawText
      result.content[1].content.lexeme.should == "world\n"
      result.content[2].should_be_kind_of WalrusGrammar::RawText
      result.content[2].lexeme.should == "...\n"
      
      # missing identifier
      lambda { @parser.parse("#block\n#end") }.should_raise Grammar::ParseError
      lambda { @parser.parse("#block ()\n#end") }.should_raise Grammar::ParseError
      
      # non-terminated parameter list
      lambda { @parser.parse("#block foo(bar\n#end") }.should_raise Grammar::ParseError
      lambda { @parser.parse("#block foo(bar,)\n#end") }.should_raise Grammar::ParseError
      
      # illegal parameter type
      lambda { @parser.parse("#block foo(1)\n#end") }.should_raise Grammar::ParseError
      lambda { @parser.parse("#block foo($bar)\n#end") }.should_raise Grammar::ParseError
      
    end
    
    specify 'should be able to parse the "def" directive' do
      
      # simple case: no parameters, no content
      result = @parser.parse("#def foo\n#end")
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should == []
      
      # pathologically short case
      result = @parser.parse('#def foo##end')
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should == []
      
      # some content
      result = @parser.parse('#def foo#hello#end')
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should_be_kind_of WalrusGrammar::RawText
      result.content.lexeme.should == 'hello'
      
      result = @parser.parse("#def foo\nhello\n#end")
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should_be_kind_of WalrusGrammar::RawText
      result.content.lexeme.should == "hello\n"
      
      # empty params list
      result = @parser.parse("#def foo()\n#end")
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params.should == []
      result.content.should == []
      
      # one param
      result = @parser.parse("#def foo(bar)\n#end")
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params.should_be_kind_of WalrusGrammar::Identifier
      result.params.lexeme.should == 'bar'
      result.content.should == []
      
      # one param with default value
      result = @parser.parse("#def foo(bar = 1)\n#end")
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params.should_be_kind_of WalrusGrammar::AssignmentExpression
      result.params.lvalue.should_be_kind_of WalrusGrammar::Identifier
      result.params.lvalue.lexeme.should == 'bar'
      result.params.expression.should_be_kind_of WalrusGrammar::NumericLiteral
      result.params.expression.lexeme.should == '1'
      result.content.should == []
      
      result = @parser.parse("#def foo(bar = nil)\n#end")
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params.should_be_kind_of WalrusGrammar::AssignmentExpression
      result.params.lvalue.should_be_kind_of WalrusGrammar::Identifier
      result.params.lvalue.lexeme.should == 'bar'
      result.params.expression.should_be_kind_of WalrusGrammar::Identifier
      result.params.expression.lexeme.should == 'nil'
      result.content.should == []
      
      # two params
      result = @parser.parse("#def foo(bar, baz)\n#end")
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'foo'
      result.params[0].should_be_kind_of WalrusGrammar::Identifier
      result.params[0].lexeme.should == 'bar'
      result.params[1].should_be_kind_of WalrusGrammar::Identifier
      result.params[1].lexeme.should == 'baz'
      result.content.should == []
      
      # nested def block
      result = @parser.parse(%Q{#def outer
hello
#def inner
world
#end
...
#end})
      result.should_be_kind_of WalrusGrammar::DefDirective
      result.identifier.to_s.should == 'outer'
      result.params.should == []
      result.content[0].should_be_kind_of WalrusGrammar::RawText
      result.content[0].lexeme.should == "hello\n"
      result.content[1].should_be_kind_of WalrusGrammar::DefDirective
      result.content[1].identifier.to_s.should == 'inner'
      result.content[1].params.should == []
      result.content[1].content.should_be_kind_of WalrusGrammar::RawText
      result.content[1].content.lexeme.should == "world\n"
      result.content[2].should_be_kind_of WalrusGrammar::RawText
      result.content[2].lexeme.should == "...\n"
      
      # missing identifier
      lambda { @parser.parse("#def\n#end") }.should_raise Grammar::ParseError
      lambda { @parser.parse("#def ()\n#end") }.should_raise Grammar::ParseError
      
      # non-terminated parameter list
      lambda { @parser.parse("#def foo(bar\n#end") }.should_raise Grammar::ParseError
      lambda { @parser.parse("#def foo(bar,)\n#end") }.should_raise Grammar::ParseError
      
      # illegal parameter type
      lambda { @parser.parse("#def foo(1)\n#end") }.should_raise Grammar::ParseError
      lambda { @parser.parse("#def foo($bar)\n#end") }.should_raise Grammar::ParseError
      
    end
    
    specify 'should be able to parse the "echo" directive' do
      
      # success case
      result = @parser.parse('#echo foo')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::EchoDirective
      result.expression.should_be_kind_of WalrusGrammar::Identifier
      result.expression.lexeme.should == 'foo'
      
      # failing case
      lambda { @parser.parse('#echo') }.should_raise Grammar::ParseError
      
      # allow multiple expressions separated by semicolons
      result = @parser.parse('#echo foo; bar')
      result.should_be_kind_of WalrusGrammar::EchoDirective
      result.expression.should_be_kind_of Array
      result.expression[0].should_be_kind_of WalrusGrammar::Identifier
      result.expression[0].lexeme.should == 'foo'
      result.expression[1].should_be_kind_of WalrusGrammar::Identifier
      result.expression[1].lexeme.should == 'bar'
      
    end
    
    specify 'should be able to parse "echo" directive, short notation' do
      
      # single expression
      result = @parser.parse('#= 1 #')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::EchoDirective
      result.expression.should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.lexeme.should == '1'
      
      # expression list
      result = @parser.parse('#= foo; bar #')
      result.should_be_kind_of WalrusGrammar::EchoDirective
      result.expression.should_be_kind_of Array
      result.expression[0].should_be_kind_of WalrusGrammar::Identifier
      result.expression[0].lexeme.should == 'foo'
      result.expression[1].should_be_kind_of WalrusGrammar::Identifier
      result.expression[1].lexeme.should == 'bar'
      
      # explicit end marker is required
      lambda { @parser.parse('#= 1') }.should_raise Grammar::ParseError
      lambda { @parser.parse('#= foo; bar') }.should_raise Grammar::ParseError
      
    end
    
    specify 'should be able to parse the "raw" directive' do
      
      # shortest example possible
      result = @parser.parse('#raw##end')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == ''
      
      # one character longer
      result = @parser.parse('#raw##end#')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == ''
      
      # same but with trailing newline instead
      result = @parser.parse("#raw##end\n")
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == ''
      
      # only slightly longer (still on one line)
      result = @parser.parse('#raw#hello world#end')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == 'hello world'
      
      result = @parser.parse('#raw#hello world#end#')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == 'hello world'
      
      result = @parser.parse("#raw#hello world#end\n")
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == 'hello world'
      
      result = @parser.parse("#raw\nhello world\n#end")
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == "hello world\n"
      
      result = @parser.parse("#raw\nhello world\n#end#")
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == "hello world\n"
      
      # with embedded directives (should be ignored)
      result = @parser.parse('#raw##def example#end')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == '#def example'
      
      # with embedded placeholders (should be ignored)
      result = @parser.parse('#raw#$foobar#end')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == '$foobar'
      
      # with embedded escapes (should be ignored)
      result = @parser.parse('#raw#\\$placeholder#end')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == '\\$placeholder'
      
      # note that you can't include a literal "#end" in the raw block
      lambda { @parser.parse('#raw# here is my #end! #end') }.should_raise Grammar::ParseError
      
      # must use a "here doc" in order to do that
      result = @parser.parse('#raw <<HERE_DOCUMENT
#end
HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == "#end\n"
      
      # optionally indented end marker
      result = @parser.parse('#raw <<-HERE_DOCUMENT
#end
HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == "#end\n"
      
      # actually indented end marker
      result = @parser.parse('#raw <<-HERE_DOCUMENT
#end
      HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == "#end\n"
      
      # empty here document
      result = @parser.parse('#raw <<HERE_DOCUMENT
HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == ''
      
      result = @parser.parse('#raw <<-HERE_DOCUMENT
HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == ''
      
      # whitespace after end marker
      result = @parser.parse('#raw <<HERE_DOCUMENT
#end
HERE_DOCUMENT     ')
      result.should_be_kind_of WalrusGrammar::RawDirective
      result.content.should == "#end\n"
      
      # invalid here document (whitespace before end marker)
      lambda { @parser.parse('#raw <<HERE_DOCUMENT
#end
    HERE_DOCUMENT') }.should_raise Grammar::ParseError
      
      # invalid here document (non-matching end marker)
      lambda { @parser.parse('#raw <<HERE_DOCUMENT
#end
THERE_DOCUMENT') }.should_raise Grammar::ParseError

    end
    
    specify 'should be able to parse the "ruby" directive' do
      
      # the end marker is required
      lambda { @parser.parse('#ruby') }.should_raise Grammar::ParseError
      lambda { @parser.parse('#ruby#foo') }.should_raise Grammar::ParseError
      
      # shortest possible version
      result = @parser.parse('#ruby##end')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == ''
      
      # two line version, also short
      result = @parser.parse("#ruby\n#end")
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == ''
      
      # simple examples with content
      result = @parser.parse('#ruby#hello world#end')
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == 'hello world'
      
      result = @parser.parse("#ruby\nfoobar#end")
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == 'foobar'
      
      # can include anything at all in the block, escape sequences, placeholders, directives etc and all will be ignored
      result = @parser.parse("#ruby\n#ignored,$ignored,\\#ignored,\\$ignored#end")
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == '#ignored,$ignored,\\#ignored,\\$ignored'
      
      # to include a literal "#end" you must use a here document
      result = @parser.parse('#ruby <<HERE_DOCUMENT
#end
HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == "#end\n"
      
      # optionally indented end marker
      result = @parser.parse('#ruby <<-HERE_DOCUMENT
#end
HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == "#end\n"
      
      # actually indented end marker
      result = @parser.parse('#ruby <<-HERE_DOCUMENT
#end
      HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == "#end\n"
      
      # empty here document
      result = @parser.parse('#ruby <<HERE_DOCUMENT
HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == ''
      
      result = @parser.parse('#ruby <<-HERE_DOCUMENT
HERE_DOCUMENT')
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == ''
      
      # whitespace after end marker
      result = @parser.parse('#ruby <<HERE_DOCUMENT
#end
HERE_DOCUMENT     ')
      result.should_be_kind_of WalrusGrammar::RubyDirective
      result.content.should == "#end\n"
      
      # invalid here document (whitespace before end marker)
      lambda { @parser.parse('#ruby <<HERE_DOCUMENT
#end
    HERE_DOCUMENT') }.should_raise Grammar::ParseError
      
      # invalid here document (non-matching end marker)
      lambda { @parser.parse('#ruby <<HERE_DOCUMENT
#end
THERE_DOCUMENT') }.should_raise Grammar::ParseError
      
    end
    
    specify 'should be able to parse the "set" directive' do
      
      # assign a string literal 
      result = @parser.parse('#set $foo = "bar"')
      result.should be_kind_of(WalrusGrammar::Directive)
      result.should be_kind_of(WalrusGrammar::SetDirective)
      result.placeholder.to_s.should == 'foo'
      result.expression.should be_kind_of(WalrusGrammar::DoubleQuotedStringLiteral)
      result.expression.lexeme.should == 'bar'
      
      # assign a local variable
      result = @parser.parse('#set $foo = bar')
      result.should be_kind_of(WalrusGrammar::SetDirective)
      result.placeholder.to_s.should == 'foo'
      result.expression.should be_kind_of(WalrusGrammar::Identifier)
      result.expression.lexeme.should == 'bar'
      
      # no whitespace allowed between "$" and placeholder name
      lambda { @parser.parse('#set $ foo = bar') }.should raise_error(Grammar::ParseError)
      
      # "long form" not allowed in #set directives
      lambda { @parser.parse('#set ${foo} = bar') }.should raise_error(Grammar::ParseError)
      
      # explicitly close directive
      result = @parser.parse('#set $foo = "bar"#')
      result.should be_kind_of(WalrusGrammar::SetDirective)
      result.placeholder.to_s.should == 'foo'
      result.expression.should be_kind_of(WalrusGrammar::DoubleQuotedStringLiteral)
      result.expression.lexeme.should == 'bar'
      
    end
    
    specify 'should be able to parse the "silent" directive' do
      
      # for more detailed tests see "should be able to parse basic Ruby expressions above"
      lambda { @parser.parse('#silent') }.should_raise Grammar::ParseError
      
      # allow multiple expressions separated by semicolons
      result = @parser.parse('#silent foo; bar')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of Array
      result.expression[0].should_be_kind_of WalrusGrammar::Identifier
      result.expression[0].lexeme.should == 'foo'
      result.expression[1].should_be_kind_of WalrusGrammar::Identifier
      result.expression[1].lexeme.should == 'bar'
      
    end
    
    specify 'should be able to parse "silent" directive, short notation' do
      
      # single expression
      result = @parser.parse('# 1 #')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of WalrusGrammar::NumericLiteral
      result.expression.lexeme.should == '1'
      
      # expression list
      result = @parser.parse('# foo; bar #')
      result.should_be_kind_of WalrusGrammar::SilentDirective
      result.expression.should_be_kind_of Array
      result.expression[0].should_be_kind_of WalrusGrammar::Identifier
      result.expression[0].lexeme.should == 'foo'
      result.expression[1].should_be_kind_of WalrusGrammar::Identifier
      result.expression[1].lexeme.should == 'bar'
      
      # more complex expression
      result = @parser.parse("#  @secret_ivar = 'foo' #")
      # note the extra space: that's officially a bug that appears when using an assignment expression
      # also happens with long form, doesn't happen for other types of expression
      
      # leading whitespace is obligatory
      lambda { @parser.parse('#1 #') }.should_raise Grammar::ParseError
      lambda { @parser.parse('#foo; bar #') }.should_raise Grammar::ParseError
      
      # explicit end marker is required
      lambda { @parser.parse('# 1') }.should_raise Grammar::ParseError
      lambda { @parser.parse('# foo; bar') }.should_raise Grammar::ParseError
      
    end
    
    specify 'should be able to parse the "slurp" directive' do
      
      # basic case
      result = @parser.parse("hello #slurp\nworld")
      result[0].should_be_kind_of WalrusGrammar::RawText
      result[0].lexeme.should == 'hello '
      result[1].should_be_kind_of WalrusGrammar::SlurpDirective
      result[2].should_be_kind_of WalrusGrammar::RawText
      result[2].lexeme.should == 'world'
      
      # must be the last thing on the line (no comments)
      lambda { @parser.parse("hello #slurp ## my comment...\nworld") }.should_raise Grammar::ParseError
      
      # but intervening whitespace is ok
      result = @parser.parse("hello #slurp     \nworld")
      result[0].should_be_kind_of WalrusGrammar::RawText
      result[0].lexeme.should == 'hello '
      result[1].should_be_kind_of WalrusGrammar::SlurpDirective
      result[2].should_be_kind_of WalrusGrammar::RawText
      result[2].lexeme.should == 'world'
      
      # should only slurp one newline, not multiple newlines
      result = @parser.parse("hello #slurp\n\n\nworld")       # three newlines
      result[0].should_be_kind_of WalrusGrammar::RawText
      result[0].lexeme.should == 'hello '
      result[1].should_be_kind_of WalrusGrammar::SlurpDirective
      result[2].should_be_kind_of WalrusGrammar::RawText
      result[2].lexeme.should == "\n\nworld"                  # one newline slurped, two left
      
    end
    
    specify 'should be able to parse the "super" directive with parentheses' do
      
      # super with empty params
      result = @parser.parse('#super()')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should == []
      
      # same with intervening whitespace
      result = @parser.parse('#super ()')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should == []
      
      # super with one param
      result = @parser.parse('#super("foo")')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params.lexeme.should == 'foo'
      result.params.to_s.should == 'foo'
      
      # same with intervening whitespace
      result = @parser.parse('#super ("foo")')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params.lexeme.should == 'foo'
      result.params.to_s.should == 'foo'
      
      # super with two params
      result = @parser.parse('#super("foo", "bar")')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should_be_kind_of Array
      result.params[0].should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params[0].lexeme.should == 'foo'
      result.params[0].to_s.should == 'foo'
      result.params[1].should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params[1].lexeme.should == 'bar'
      result.params[1].to_s.should == 'bar'
      
      # same with intervening whitespace
      result = @parser.parse('#super ("foo", "bar")')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should_be_kind_of Array
      result.params[0].should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params[0].lexeme.should == 'foo'
      result.params[0].to_s.should == 'foo'
      result.params[1].should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params[1].lexeme.should == 'bar'
      result.params[1].to_s.should == 'bar'
      
    end
    
    specify 'should be able to parse the "super" directive without parentheses' do
      
      # super with no params
      result = @parser.parse('#super')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should == []
      
      # super with one param
      result = @parser.parse('#super "foo"')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params.lexeme.should == 'foo'
      result.params.to_s.should == 'foo'
      
      # super with two params
      result = @parser.parse('#super "foo", "bar"')
      result.should_be_kind_of WalrusGrammar::SuperDirective
      result.params.should_be_kind_of Array
      result.params[0].should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params[0].lexeme.should == 'foo'
      result.params[0].to_s.should == 'foo'
      result.params[1].should_be_kind_of WalrusGrammar::DoubleQuotedStringLiteral
      result.params[1].lexeme.should == 'bar'
      result.params[1].to_s.should == 'bar'
      
    end
    
    specify 'parse results should contain information about their location in the original source (line and column start/end)' do
      
      # simple raw text
      result = @parser.parse('hello world')
      result.line_start.should    == 0  # where the node starts
      result.column_start.should  == 0  # where the node starts
      result.line_end.should      == 0  # how far the parser got
      result.column_end.should    == 11 # how far the parser got
      
      # super with two params
      result = @parser.parse('#super "foo", "bar"')
      result.line_start.should              == 0
      result.column_start.should            == 0
      result.line_end.should                == 0
      result.column_end.should              == 19
      result.params.line_start.should       == 0
#      result.params.column_start.should     == 7 # get 0
      result.params.line_end.should         == 0
      result.params.column_end.should       == 19
      result.params[0].line_start.should    == 0
      result.params[0].column_start.should  == 7
      result.params[0].line_end.should      == 0
      result.params[0].column_end.should    == 12
      result.params[1].line_start.should    == 0
#      result.params[1].column_start.should  == 14 # get 12
      result.params[1].line_end.should      == 0
      result.params[1].column_end.should    == 19
      
    end
    
    specify 'ParseErrors should contain information about the location of the problem' do
      
      # error at beginning of string (unknown directive)
      begin
        @parser.parse('#sooper')
      rescue Grammar::ParseError => e
        exception = e
      end
      exception.line_start.should     == 0
      exception.column_start.should   == 0
      exception.line_end.should       == 0
      exception.column_end.should     == 0
      
      # error on second line (unknown directive)
      begin
        @parser.parse("## a comment\n#sooper")
      rescue Grammar::ParseError => e
        exception = e
      end
      exception.line_start.should     == 0
      exception.column_start.should   == 0
      exception.line_end.should       == 1
      exception.column_end.should     == 0
      
      # error at end of second line (missing closing bracket)
      begin
        @parser.parse("## a comment\n#super (1, 2")
      rescue Grammar::ParseError => e
        exception = e
      end
      exception.line_start.should     == 0
      exception.column_start.should   == 0
      exception.line_end.should       == 1
#      exception.column_end.should     == 12 # returns 0, which is almost right... but we want the rightmost coordinate, not the beginning of the busted directive
      
      # here the error was returned at line 1, column 0 (the very beginning of the #super directive)
      # but we really would have preferred it to be reported at column 12 (the missing closing bracket)
      # to get to the rightmost point the parser will have had to follow this path:
      # - try to scan a directive
      # - try to scan a super directive
      # - try to scan a parameter list
      # - try to scan a paremeter etc
      
    end
    
    specify 'produced AST nodes should contain information about their location in the source file' do
      
    end
    
  end
  
end # module Walrus

