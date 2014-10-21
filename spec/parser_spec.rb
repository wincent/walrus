# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

describe Walrus::Parser do
  describe 'parsing raw text, escape markers and comments' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should be able to instantiate the parser' do
      expect(@parser).not_to be_nil
    end

    it 'should be able to parse a plaintext string' do
      # a single word
      result = @parser.parse('foo')
      expect(result).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.lexeme).to eq('foo')

      # multiple words
      result = @parser.parse('foo bar')
      expect(result).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.lexeme).to eq('foo bar')

      # multiple lines
      result = @parser.parse("hello\nworld")
      expect(result).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.lexeme).to eq("hello\nworld")
    end

    it 'should be able to parse a comment' do
      # comment with content
      result = @parser.parse('## hello world')
      expect(result).to be_kind_of(Walrus::Grammar::Comment)
      expect(result.lexeme).to eq(' hello world')

      # comment with no content
      result = @parser.parse('##')
      expect(result).to be_kind_of(Walrus::Grammar::Comment)
      expect(result.lexeme).to eq('')

      # multi-line comment (empty)
      result = @parser.parse('#**#')
      expect(result).to be_kind_of(Walrus::Grammar::Comment)
      expect(result).to be_kind_of(Walrus::Grammar::MultilineComment)
      expect(result.content).to eq('')

      # multi-line comment (with content)
      result = @parser.parse('#* hello world *#')
      expect(result).to be_kind_of(Walrus::Grammar::MultilineComment)
      expect(result.content).to eq(' hello world ')

      # multi-line comment (spanning multiple lines)
      result = @parser.parse("#* hello\nworld *#")
      expect(result).to be_kind_of(Walrus::Grammar::MultilineComment)
      expect(result.content).to eq(" hello\nworld ")

      # multi-line comment (with nested comment)
      result = @parser.parse('#* hello #*world*# *#')
      expect(result).to be_kind_of(Walrus::Grammar::MultilineComment)
      expect(result.content[0]).to eq(' hello ')
      expect(result.content[1]).to be_kind_of(Walrus::Grammar::MultilineComment)
      expect(result.content[1].content).to eq('world')
      expect(result.content[2]).to eq(' ')

      # multi-line comment (with nested comment, spanning multiple lines)
      result = @parser.parse("#* hello\n#* world\n... *# *#")
      expect(result).to be_kind_of(Walrus::Grammar::MultilineComment)
      expect(result.content[0]).to eq(" hello\n")
      expect(result.content[1]).to be_kind_of(Walrus::Grammar::MultilineComment)
      expect(result.content[1].content).to eq(" world\n... ")
      expect(result.content[2]).to eq(' ')

      # multi-line comment (with nested single-line comment)
      result = @parser.parse("#* ##hello\n*#")
      expect(result).to be_kind_of(Walrus::Grammar::MultilineComment)
      expect(result.content[0]).to eq(' ')
      expect(result.content[1]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result.content[1].lexeme).to eq('hello') # here the newline gets eaten
    end

    it 'should be able to parse an escape marker' do
      # directive marker
      result = @parser.parse('\\#')
      expect(result).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result.lexeme).to eq('#')

      # placeholder marker
      result = @parser.parse('\\$')
      expect(result).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result.lexeme).to eq('$')

      # escape marker
      result = @parser.parse('\\\\')
      expect(result).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result.lexeme).to eq('\\')

      # multiple escape markers
      result = @parser.parse('\\#\\$\\\\')
      expect(result[0]).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result[0].lexeme).to eq('#')
      expect(result[1]).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result[1].lexeme).to eq('$')
      expect(result[2]).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result[2].lexeme).to eq('\\')
    end

    it 'should complain on finding an illegal escape marker' do
      # invalid character
      expect do
        @parser.parse('\\x')
      end.to raise_error(Walrat::ParseError)

      # no character
      expect do
        @parser.parse('\\')
      end.to raise_error(Walrat::ParseError)
    end

    it 'should be able to mix comments and plain text' do
      # plain text followed by comment
      result = @parser.parse('foobar ## hello world')
      expect(result[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[0].lexeme).to eq('foobar ')
      expect(result[1]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result[1].lexeme).to eq(' hello world')

      # comment should only extend up until the next newline
      result = @parser.parse("## hello world\nfoobar")
      expect(result[0]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result[0].lexeme).to eq(' hello world')
    end

    it 'should be able to mix escape markers and plain text' do
      # plain text followed by an escape marker
      result = @parser.parse('hello \\#')
      expect(result[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[0].lexeme).to eq('hello ')
      expect(result[1]).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result[1].lexeme).to eq('#')

      # an escape marker followed by plain text
      result = @parser.parse('\\$hello')
      expect(result[0]).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result[0].lexeme).to eq('$')
      expect(result[1]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[1].lexeme).to eq('hello')

      # alternation
      result = @parser.parse('hello \\\\ world')
      expect(result[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[0].lexeme).to eq('hello ')
      expect(result[1]).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result[1].lexeme).to eq('\\')
      expect(result[2]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[2].lexeme).to eq(' world')

      # with newlines thrown into the mix
      result = @parser.parse("hello\n\\#")
      expect(result[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[0].lexeme).to eq("hello\n")
      expect(result[1]).to be_kind_of(Walrus::Grammar::EscapeSequence)
      expect(result[1].lexeme).to eq('#')
    end
  end

  describe 'parsing directives' do
    before do
      @parser = Walrus::Parser.new
    end

    it 'should complain on encountering an unknown or invalid directive name' do
      expect { @parser.parse('#glindenburgen') }.to raise_error(Walrat::ParseError)
      expect { @parser.parse('#') }.to raise_error(Walrat::ParseError)
    end

    it 'should complain if there is whitespace between the directive marker (#) and the directive name' do
      expect { @parser.parse('# extends "other_template"') }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to parse a directive that takes a single parameter' do
      result = @parser.parse('#extends "other_template"')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::ExtendsDirective)
      expect(result.class_name.lexeme).to eq('other_template')
    end

    it 'should be able to follow a directive by a comment on the same line, only if the directive has an explicit termination marker' do
      # no intervening whitespace ("extends" directive, takes one parameter)
      result = @parser.parse('#extends "other_template"### comment')
      expect(result[0]).to be_kind_of(Walrus::Grammar::ExtendsDirective)
      expect(result[0].class_name.lexeme).to eq('other_template')
      expect(result[1]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result[1].lexeme).to eq(' comment')

      # counter-example
      expect { @parser.parse('#extends "other_template"## comment') }.to raise_error(Walrat::ParseError)

      # intervening whitespace (between parameter and trailing comment)
      result = @parser.parse('#extends "other_template"           ### comment')
      expect(result[0]).to be_kind_of(Walrus::Grammar::ExtendsDirective)
      expect(result[0].class_name.lexeme).to eq('other_template')
      expect(result[1]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result[1].lexeme).to eq(' comment')

      # counter-example
      expect { @parser.parse('#extends "other_template"           ## comment') }.to raise_error(Walrat::ParseError)

      # intervening whitespace (between directive and parameter)
      result = @parser.parse('#extends          "other_template"           ### comment')
      expect(result[0]).to be_kind_of(Walrus::Grammar::ExtendsDirective)
      expect(result[0].class_name.lexeme).to eq('other_template')
      expect(result[1]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result[1].lexeme).to eq(' comment')

      # counter-example
      expect { @parser.parse('#extends          "other_template"           ## comment') }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to span directives across lines by using a line continuation backslash' do
      # basic case
      result = @parser.parse("#extends \\\n'other_template'")
      expect(result).to be_kind_of(Walrus::Grammar::ExtendsDirective)
      expect(result.class_name.lexeme).to eq('other_template')

      # should fail if backslash is not the last character on the line
      expect { @parser.parse("#extends \\ \n'other_template'") }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to parse an "import" directive' do
      # followed by a newline
      result = @parser.parse("#import 'other_template'\nhello")
      expect(result[0]).to be_kind_of(Walrus::Grammar::ImportDirective)
      expect(result[0].class_name.lexeme).to eq('other_template')
      expect(result[1]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[1].lexeme).to eq('hello') # newline gets eaten

      # followed by whitespace
      result = @parser.parse('#import "other_template"     ')
      expect(result).to be_kind_of(Walrus::Grammar::ImportDirective)
      expect(result.class_name.lexeme).to eq('other_template')

      # followed by the end of the input
      result = @parser.parse('#import "other_template"')
      expect(result).to be_kind_of(Walrus::Grammar::ImportDirective)
      expect(result.class_name.lexeme).to eq('other_template')

      # comment with no intervening whitespace
      result = @parser.parse('#import "other_template"### comment')
      expect(result[0]).to be_kind_of(Walrus::Grammar::ImportDirective)
      expect(result[0].class_name.lexeme).to eq('other_template')
      expect(result[1]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result[1].lexeme).to eq(' comment')

      # counter-example
      expect { @parser.parse('#import "other_template"## comment') }.to raise_error(Walrat::ParseError)

      # intervening whitespace (between parameter and trailing comment)
      result = @parser.parse('#import "other_template"           ### comment')
      expect(result[0]).to be_kind_of(Walrus::Grammar::ImportDirective)
      expect(result[0].class_name.lexeme).to eq('other_template')
      expect(result[1]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result[1].lexeme).to eq(' comment')

      # counter-example
      expect { @parser.parse('#import "other_template"           ## comment') }.to raise_error(Walrat::ParseError)

      # intervening whitespace (between directive and parameter)
      result = @parser.parse('#import          "other_template"           ### comment')
      expect(result[0]).to be_kind_of(Walrus::Grammar::ImportDirective)
      expect(result[0].class_name.lexeme).to eq('other_template')
      expect(result[1]).to be_kind_of(Walrus::Grammar::Comment)
      expect(result[1].lexeme).to eq(' comment')

      # counter-example
      expect { @parser.parse('#import          "other_template"           ## comment') }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to parse single quoted string literals' do
      # string literals have no special meaning when part of raw text
      result = @parser.parse("'hello'")
      expect(result).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.lexeme).to eq("'hello'")

      # empty string
      result = @parser.parse("#import ''")
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::SingleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq([])

      # with escaped single quotes inside
      result = @parser.parse("#import 'hello \\'world\\''")
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::SingleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq("hello \\'world\\'")

      # with other escapes inside
      result = @parser.parse("#import 'hello\\nworld'")
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::SingleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello\nworld')

      # with double quotes inside
      result = @parser.parse("#import 'hello \"world\"'")
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::SingleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello "world"')

      # with Walrus comments inside (ignored)
      result = @parser.parse("#import 'hello ##world'")
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::SingleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello ##world')

      # with Walrus placeholders inside (no interpolation)
      result = @parser.parse("#import 'hello $world'")
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::SingleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello $world')

      # with Walrus directives inside (no interpolation)
      result = @parser.parse("#import 'hello #end'")
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::SingleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello #end')
    end

    it 'should be able to parse double quoted string literals' do
      # string literals have no special meaning when part of raw text
      result = @parser.parse('"hello"')
      expect(result).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.lexeme).to eq('"hello"')

      # empty string
      result = @parser.parse('#import ""')
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq([])

      # with escaped double quotes inside
      result = @parser.parse('#import "hello \\"world\\""')
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello \\"world\\"')

      # with other escapes inside
      result = @parser.parse('#import "hello\\nworld"')
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello\\nworld')

      # with single quotes inside
      result = @parser.parse('#import "hello \'world\'"')
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq("hello 'world'")

      # with Walrus comments inside (ignored)
      result = @parser.parse('#import "hello ##world"')
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello ##world')

      # with Walrus placeholders inside (no interpolation)
      result = @parser.parse('#import "hello $world"')
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello $world')

      # with Walrus directives inside (no interpolation)
      result = @parser.parse('#import "hello #end"')
      expect(result.class_name).to be_kind_of(Walrus::Grammar::StringLiteral)
      expect(result.class_name).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.class_name.lexeme).to eq('hello #end')
    end

    # will use the #silent directive here because it's an easy way to make the parser look for a ruby expression
    it 'should be able to parse basic Ruby expressions' do
      # a numeric literal
      result = @parser.parse('#silent 1')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.lexeme).to eq('1')

      # a single-quoted string literal
      result = @parser.parse("#silent 'foo'")
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::SingleQuotedStringLiteral)
      expect(result.expression.lexeme).to eq('foo')

      # a double-quoted string literal
      result = @parser.parse('#silent "foo"')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.expression.lexeme).to eq('foo')

      # an identifier
      result = @parser.parse('#silent foo')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.lexeme).to eq('foo')

      result = @parser.parse('#silent foo_bar')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.lexeme).to eq('foo_bar')

      # a constant
      result = @parser.parse('#silent Foo')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::Constant)
      expect(result.expression.lexeme).to eq('Foo')

      result = @parser.parse('#silent FooBar')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::Constant)
      expect(result.expression.lexeme).to eq('FooBar')

      # a symbol
      result = @parser.parse('#silent :foo')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::SymbolLiteral)
      expect(result.expression.lexeme).to eq(':foo')

      result = @parser.parse('#silent :Foo')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::SymbolLiteral)
      expect(result.expression.lexeme).to eq(':Foo')

      # an array literal
      result = @parser.parse('#silent [1]')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::RubyExpression)
      expect(result.expression).to be_kind_of(Walrus::Grammar::ArrayLiteral)
      expect(result.expression.elements).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.elements.lexeme).to eq('1')

      result = @parser.parse('#silent [1, 2, 3]')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::RubyExpression)
      expect(result.expression).to be_kind_of(Walrus::Grammar::ArrayLiteral)
      expect(result.expression.elements).to be_kind_of(Array)
      expect(result.expression.elements[0]).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.elements[0].lexeme).to eq('1')
      expect(result.expression.elements[1]).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.elements[1].lexeme).to eq('2')
      expect(result.expression.elements[2]).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.elements[2].lexeme).to eq('3')

      # a hash literal
      result = @parser.parse('#silent { :foo => "bar" }')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::RubyExpression)
      expect(result.expression).to be_kind_of(Walrus::Grammar::HashLiteral)
      expect(result.expression.pairs).to be_kind_of(Walrus::Grammar::RubyExpression)
      expect(result.expression.pairs).to be_kind_of(Walrus::Grammar::HashAssignment)
      expect(result.expression.pairs.lvalue).to be_kind_of(Walrus::Grammar::SymbolLiteral)
      expect(result.expression.pairs.lvalue.lexeme).to eq(':foo')
      expect(result.expression.pairs.expression).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.expression.pairs.expression.lexeme).to eq('bar')

      result = @parser.parse('#silent { :foo => "bar", :baz => "xyz" }')
      expect(result.expression).to be_kind_of(Walrus::Grammar::HashLiteral)
      expect(result.expression.pairs).to be_kind_of(Array)
      expect(result.expression.pairs[0]).to be_kind_of(Walrus::Grammar::HashAssignment)
      expect(result.expression.pairs[0].lvalue).to be_kind_of(Walrus::Grammar::SymbolLiteral)
      expect(result.expression.pairs[0].lvalue.lexeme).to eq(':foo')
      expect(result.expression.pairs[0].expression).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.expression.pairs[0].expression.lexeme).to eq('bar')
      expect(result.expression.pairs[1]).to be_kind_of(Walrus::Grammar::HashAssignment)
      expect(result.expression.pairs[1].lvalue).to be_kind_of(Walrus::Grammar::SymbolLiteral)
      expect(result.expression.pairs[1].lvalue.lexeme).to eq(':baz')
      expect(result.expression.pairs[1].expression).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.expression.pairs[1].expression.lexeme).to eq('xyz')

      # an addition expression
      result = @parser.parse('#silent 1 + 2')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::RubyExpression)
      expect(result.expression).to be_kind_of(Walrus::Grammar::AdditionExpression)
      expect(result.expression.left).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.left.lexeme).to eq('1')
      expect(result.expression.right).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.right.lexeme).to eq('2')

      # an assignment expression
      result = @parser.parse('#silent foo = 1')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::RubyExpression)
      expect(result.expression).to be_kind_of(Walrus::Grammar::AssignmentExpression)
      expect(result.expression.lvalue).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.lvalue.lexeme).to eq('foo')
      expect(result.expression.expression).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.expression.lexeme).to eq('1')

      # a method invocation
      result = @parser.parse('#silent foo.delete')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::RubyExpression)
      expect(result.expression).to be_kind_of(Walrus::Grammar::MessageExpression)

      result = @parser.parse('#silent foo.delete()')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::MessageExpression)
      expect(result.expression.target).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.target.lexeme).to eq('foo')
      expect(result.expression.message).to be_kind_of(Walrus::Grammar::RubyExpression)
      expect(result.expression.message).to be_kind_of(Walrus::Grammar::MethodExpression)
      expect(result.expression.message.name).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.message.name.lexeme).to eq('delete')
      expect(result.expression.message.params).to be_kind_of(Array)
      expect(result.expression.message.params).to eq([])

      result = @parser.parse('#silent foo.delete(1)')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::MessageExpression)
      expect(result.expression.target).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.target.lexeme).to eq('foo')
      expect(result.expression.message).to be_kind_of(Walrus::Grammar::MethodExpression)
      expect(result.expression.message.name).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.message.name.lexeme).to eq('delete')
      expect(result.expression.message.params).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.message.params.lexeme).to eq('1')

      result = @parser.parse('#silent foo.delete(bar, baz)')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::MessageExpression)
      expect(result.expression.target).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.target.lexeme).to eq('foo')
      expect(result.expression.message).to be_kind_of(Walrus::Grammar::MethodExpression)
      expect(result.expression.message.name).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.message.name.lexeme).to eq('delete')
      expect(result.expression.message.params).to be_kind_of(Array)
      expect(result.expression.message.params[0]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.message.params[0].lexeme).to eq('bar')
      expect(result.expression.message.params[1]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.message.params[1].lexeme).to eq('baz')

      # chained method invocation
      result = @parser.parse('#silent foo.bar.baz')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::MessageExpression)
      expect(result.expression.target).to be_kind_of(Walrus::Grammar::MessageExpression)
      expect(result.expression.target.target).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.target.target.lexeme.to_s).to eq('foo')
      expect(result.expression.target.message).to be_kind_of(Walrus::Grammar::MethodExpression)
      expect(result.expression.target.message.name).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.target.message.name.lexeme.to_s).to eq('bar')
      expect(result.expression.target.message.params).to eq([])
      expect(result.expression.message).to be_kind_of(Walrus::Grammar::MethodExpression)
      expect(result.expression.message.name).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.message.name.lexeme.to_s).to eq('baz')
      expect(result.expression.message.params).to eq([])

      # chained method invocation with arguments
      result = @parser.parse('#silent foo.bar(1).baz')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::MessageExpression)

      result = @parser.parse('#silent foo.bar.baz(2)')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::MessageExpression)

      result = @parser.parse('#silent foo.bar(1).baz(2)')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::MessageExpression)

      # nested arrays
      result = @parser.parse('#silent [1, 2, [foo, bar]]')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::ArrayLiteral)
      expect(result.expression.elements).to be_kind_of(Array)
      expect(result.expression.elements[0]).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.elements[0].lexeme.to_s).to eq('1')
      expect(result.expression.elements[1]).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.elements[1].lexeme.to_s).to eq('2')
      expect(result.expression.elements[2]).to be_kind_of(Walrus::Grammar::ArrayLiteral)
      expect(result.expression.elements[2].elements).to be_kind_of(Array)
      expect(result.expression.elements[2].elements[0]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.elements[2].elements[0].lexeme.to_s).to eq('foo')
      expect(result.expression.elements[2].elements[1]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.elements[2].elements[1].lexeme.to_s).to eq('bar')

      # nesting in a hash
      result = @parser.parse('#silent { :foo => [1, 2] }')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::HashLiteral)

      # multiple addition expressions
      result = @parser.parse('#silent 1 + 2 + 3')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::AdditionExpression)
      expect(result.expression.left).to be_kind_of(Walrus::Grammar::AdditionExpression)
      expect(result.expression.left.left).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.left.left.lexeme.to_s).to eq('1')
      expect(result.expression.left.right).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.left.right.lexeme.to_s).to eq('2')
      expect(result.expression.right).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.right.lexeme.to_s).to eq('3')

      # addition and assignment
      result = @parser.parse('#silent foo = bar + 1')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::AssignmentExpression)
    end

    it 'should be able go from AST representation of a Ruby expression to an evaluable string form' do
      result = @parser.parse('#silent 1 + 2 + 3')

      # given that ruby expressions might be able to contain placeholders, i am not sure if a simple "reverse to original string" method will be enough...
    end

    it 'should be able to parse the "block" directive' do
      # simple case: no parameters, no content
      result = @parser.parse("#block foo\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to eq([])

      # pathologically short case
      result = @parser.parse('#block foo##end')
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to eq([])

      # some content
      result = @parser.parse('#block foo#hello#end')
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content.lexeme).to eq('hello')

      result = @parser.parse("#block foo\nhello\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content.lexeme).to eq("hello\n")

      # empty params list
      result = @parser.parse("#block foo()\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to eq([])

      # one param
      result = @parser.parse("#block foo(bar)\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params.lexeme).to eq('bar')
      expect(result.content).to eq([])

      # one param with blockault value
      result = @parser.parse("#block foo(bar = 1)\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to be_kind_of(Walrus::Grammar::AssignmentExpression)
      expect(result.params.lvalue).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params.lvalue.lexeme).to eq('bar')
      expect(result.params.expression).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.params.expression.lexeme).to eq('1')
      expect(result.content).to eq([])

      result = @parser.parse("#block foo(bar = nil)\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to be_kind_of(Walrus::Grammar::AssignmentExpression)
      expect(result.params.lvalue).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params.lvalue.lexeme).to eq('bar')
      expect(result.params.expression).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params.expression.lexeme).to eq('nil')
      expect(result.content).to eq([])

      # two params
      result = @parser.parse("#block foo(bar, baz)\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params[0]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params[0].lexeme).to eq('bar')
      expect(result.params[1]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params[1].lexeme).to eq('baz')
      expect(result.content).to eq([])

      # nested block block
      result = @parser.parse(%Q{#block outer
hello
#block inner
world
#end
...
#end})
      expect(result).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.identifier.to_s).to eq('outer')
      expect(result.params).to eq([])
      expect(result.content[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content[0].lexeme).to eq("hello\n")
      expect(result.content[1]).to be_kind_of(Walrus::Grammar::BlockDirective)
      expect(result.content[1].identifier.to_s).to eq('inner')
      expect(result.content[1].params).to eq([])
      expect(result.content[1].content).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content[1].content.lexeme).to eq("world\n")
      expect(result.content[2]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content[2].lexeme).to eq("...\n")

      # missing identifier
      expect { @parser.parse("#block\n#end") }.to raise_error(Walrat::ParseError)
      expect { @parser.parse("#block ()\n#end") }.to raise_error(Walrat::ParseError)

      # non-terminated parameter list
      expect { @parser.parse("#block foo(bar\n#end") }.to raise_error(Walrat::ParseError)
      expect { @parser.parse("#block foo(bar,)\n#end") }.to raise_error(Walrat::ParseError)

      # illegal parameter type
      expect { @parser.parse("#block foo(1)\n#end") }.to raise_error(Walrat::ParseError)
      expect { @parser.parse("#block foo($bar)\n#end") }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to parse the "def" directive' do
      # simple case: no parameters, no content
      result = @parser.parse("#def foo\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to eq([])

      # pathologically short case
      result = @parser.parse('#def foo##end')
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to eq([])

      # some content
      result = @parser.parse('#def foo#hello#end')
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content.lexeme).to eq('hello')

      result = @parser.parse("#def foo\nhello\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content.lexeme).to eq("hello\n")

      # empty params list
      result = @parser.parse("#def foo()\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to eq([])
      expect(result.content).to eq([])

      # one param
      result = @parser.parse("#def foo(bar)\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params.lexeme).to eq('bar')
      expect(result.content).to eq([])

      # one param with default value
      result = @parser.parse("#def foo(bar = 1)\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to be_kind_of(Walrus::Grammar::AssignmentExpression)
      expect(result.params.lvalue).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params.lvalue.lexeme).to eq('bar')
      expect(result.params.expression).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.params.expression.lexeme).to eq('1')
      expect(result.content).to eq([])

      result = @parser.parse("#def foo(bar = nil)\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params).to be_kind_of(Walrus::Grammar::AssignmentExpression)
      expect(result.params.lvalue).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params.lvalue.lexeme).to eq('bar')
      expect(result.params.expression).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params.expression.lexeme).to eq('nil')
      expect(result.content).to eq([])

      # two params
      result = @parser.parse("#def foo(bar, baz)\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('foo')
      expect(result.params[0]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params[0].lexeme).to eq('bar')
      expect(result.params[1]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.params[1].lexeme).to eq('baz')
      expect(result.content).to eq([])

      # nested def block
      result = @parser.parse(%Q{#def outer
hello
#def inner
world
#end
...
#end})
      expect(result).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.identifier.to_s).to eq('outer')
      expect(result.params).to eq([])
      expect(result.content[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content[0].lexeme).to eq("hello\n")
      expect(result.content[1]).to be_kind_of(Walrus::Grammar::DefDirective)
      expect(result.content[1].identifier.to_s).to eq('inner')
      expect(result.content[1].params).to eq([])
      expect(result.content[1].content).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content[1].content.lexeme).to eq("world\n")
      expect(result.content[2]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result.content[2].lexeme).to eq("...\n")

      # missing identifier
      expect { @parser.parse("#def\n#end") }.to raise_error(Walrat::ParseError)
      expect { @parser.parse("#def ()\n#end") }.to raise_error(Walrat::ParseError)

      # non-terminated parameter list
      expect { @parser.parse("#def foo(bar\n#end") }.to raise_error(Walrat::ParseError)
      expect { @parser.parse("#def foo(bar,)\n#end") }.to raise_error(Walrat::ParseError)

      # illegal parameter type
      expect { @parser.parse("#def foo(1)\n#end") }.to raise_error(Walrat::ParseError)
      expect { @parser.parse("#def foo($bar)\n#end") }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to parse the "echo" directive' do
      # success case
      result = @parser.parse('#echo foo')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::EchoDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.lexeme).to eq('foo')

      # failing case
      expect { @parser.parse('#echo') }.to raise_error(Walrat::ParseError)

      # allow multiple expressions separated by semicolons
      result = @parser.parse('#echo foo; bar')
      expect(result).to be_kind_of(Walrus::Grammar::EchoDirective)
      expect(result.expression).to be_kind_of(Array)
      expect(result.expression[0]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression[0].lexeme).to eq('foo')
      expect(result.expression[1]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression[1].lexeme).to eq('bar')
    end

    it 'should be able to parse "echo" directive, short notation' do
      # single expression
      result = @parser.parse('#= 1 #')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::EchoDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.lexeme).to eq('1')

      # expression list
      result = @parser.parse('#= foo; bar #')
      expect(result).to be_kind_of(Walrus::Grammar::EchoDirective)
      expect(result.expression).to be_kind_of(Array)
      expect(result.expression[0]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression[0].lexeme).to eq('foo')
      expect(result.expression[1]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression[1].lexeme).to eq('bar')

      # explicit end marker is required
      expect { @parser.parse('#= 1') }.to raise_error(Walrat::ParseError)
      expect { @parser.parse('#= foo; bar') }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to parse the "raw" directive' do
      # shortest example possible
      result = @parser.parse('#raw##end')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('')

      # one character longer
      result = @parser.parse('#raw##end#')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('')

      # same but with trailing newline instead
      result = @parser.parse("#raw##end\n")
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('')

      # only slightly longer (still on one line)
      result = @parser.parse('#raw#hello world#end')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('hello world')

      result = @parser.parse('#raw#hello world#end#')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('hello world')

      result = @parser.parse("#raw#hello world#end\n")
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('hello world')

      result = @parser.parse("#raw\nhello world\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq("hello world\n")

      result = @parser.parse("#raw\nhello world\n#end#")
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq("hello world\n")

      # with embedded directives (should be ignored)
      result = @parser.parse('#raw##def example#end')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('#def example')

      # with embedded placeholders (should be ignored)
      result = @parser.parse('#raw#$foobar#end')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('$foobar')

      # with embedded escapes (should be ignored)
      result = @parser.parse('#raw#\\$placeholder#end')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('\\$placeholder')

      # note that you can't include a literal "#end" in the raw block
      expect { @parser.parse('#raw# here is my #end! #end') }.to raise_error(Walrat::ParseError)

      # must use a "here doc" in order to do that
      result = @parser.parse('#raw <<HERE_DOCUMENT
#end
HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq("#end\n")

      # optionally indented end marker
      result = @parser.parse('#raw <<-HERE_DOCUMENT
#end
HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq("#end\n")

      # actually indented end marker
      result = @parser.parse('#raw <<-HERE_DOCUMENT
#end
      HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq("#end\n")

      # empty here document
      result = @parser.parse('#raw <<HERE_DOCUMENT
HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('')

      result = @parser.parse('#raw <<-HERE_DOCUMENT
HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq('')

      # whitespace after end marker
      result = @parser.parse('#raw <<HERE_DOCUMENT
#end
HERE_DOCUMENT     ')
      expect(result).to be_kind_of(Walrus::Grammar::RawDirective)
      expect(result.content).to eq("#end\n")

      # invalid here document (whitespace before end marker)
      expect { @parser.parse('#raw <<HERE_DOCUMENT
#end
    HERE_DOCUMENT') }.to raise_error(Walrat::ParseError)

      # invalid here document (non-matching end marker)
      expect { @parser.parse('#raw <<HERE_DOCUMENT
#end
THERE_DOCUMENT') }.to raise_error(Walrat::ParseError)

    end

    it 'should be able to parse the "ruby" directive' do
      # the end marker is required
      expect { @parser.parse('#ruby') }.to raise_error(Walrat::ParseError)
      expect { @parser.parse('#ruby#foo') }.to raise_error(Walrat::ParseError)

      # shortest possible version
      result = @parser.parse('#ruby##end')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq('')

      # two line version, also short
      result = @parser.parse("#ruby\n#end")
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq('')

      # simple examples with content
      result = @parser.parse('#ruby#hello world#end')
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq('hello world')

      result = @parser.parse("#ruby\nfoobar#end")
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq('foobar')

      # can include anything at all in the block, escape sequences, placeholders, directives etc and all will be ignored
      result = @parser.parse("#ruby\n#ignored,$ignored,\\#ignored,\\$ignored#end")
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq('#ignored,$ignored,\\#ignored,\\$ignored')

      # to include a literal "#end" you must use a here document
      result = @parser.parse('#ruby <<HERE_DOCUMENT
#end
HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq("#end\n")

      # optionally indented end marker
      result = @parser.parse('#ruby <<-HERE_DOCUMENT
#end
HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq("#end\n")

      # actually indented end marker
      result = @parser.parse('#ruby <<-HERE_DOCUMENT
#end
      HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq("#end\n")

      # empty here document
      result = @parser.parse('#ruby <<HERE_DOCUMENT
HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq('')

      result = @parser.parse('#ruby <<-HERE_DOCUMENT
HERE_DOCUMENT')
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq('')

      # whitespace after end marker
      result = @parser.parse('#ruby <<HERE_DOCUMENT
#end
HERE_DOCUMENT     ')
      expect(result).to be_kind_of(Walrus::Grammar::RubyDirective)
      expect(result.content).to eq("#end\n")

      # invalid here document (whitespace before end marker)
      expect { @parser.parse('#ruby <<HERE_DOCUMENT
#end
    HERE_DOCUMENT') }.to raise_error(Walrat::ParseError)

      # invalid here document (non-matching end marker)
      expect { @parser.parse('#ruby <<HERE_DOCUMENT
#end
THERE_DOCUMENT') }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to parse the "set" directive' do
      # assign a string literal
      result = @parser.parse('#set $foo = "bar"')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SetDirective)
      expect(result.placeholder.to_s).to eq('foo')
      expect(result.expression).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.expression.lexeme).to eq('bar')

      # assign a local variable
      result = @parser.parse('#set $foo = bar')
      expect(result).to be_kind_of(Walrus::Grammar::SetDirective)
      expect(result.placeholder.to_s).to eq('foo')
      expect(result.expression).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression.lexeme).to eq('bar')

      # no whitespace allowed between "$" and placeholder name
      expect { @parser.parse('#set $ foo = bar') }.to raise_error(Walrat::ParseError)

      # "long form" not allowed in #set directives
      expect { @parser.parse('#set ${foo} = bar') }.to raise_error(Walrat::ParseError)

      # explicitly close directive
      result = @parser.parse('#set $foo = "bar"#')
      expect(result).to be_kind_of(Walrus::Grammar::SetDirective)
      expect(result.placeholder.to_s).to eq('foo')
      expect(result.expression).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.expression.lexeme).to eq('bar')
    end

    it 'should be able to parse the "silent" directive' do
      # for more detailed tests see "should be able to parse basic Ruby expressions above"
      expect { @parser.parse('#silent') }.to raise_error(Walrat::ParseError)

      # allow multiple expressions separated by semicolons
      result = @parser.parse('#silent foo; bar')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Array)
      expect(result.expression[0]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression[0].lexeme).to eq('foo')
      expect(result.expression[1]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression[1].lexeme).to eq('bar')
    end

    it 'should be able to parse "silent" directive, short notation' do
      # single expression
      result = @parser.parse('# 1 #')
      expect(result).to be_kind_of(Walrus::Grammar::Directive)
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Walrus::Grammar::NumericLiteral)
      expect(result.expression.lexeme).to eq('1')

      # expression list
      result = @parser.parse('# foo; bar #')
      expect(result).to be_kind_of(Walrus::Grammar::SilentDirective)
      expect(result.expression).to be_kind_of(Array)
      expect(result.expression[0]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression[0].lexeme).to eq('foo')
      expect(result.expression[1]).to be_kind_of(Walrus::Grammar::Identifier)
      expect(result.expression[1].lexeme).to eq('bar')

      # more complex expression
      result = @parser.parse("# @secret_ivar = 'foo' #")
      result = @parser.parse("# foo + bar #")
      result = @parser.parse("# foo.bar #")
      result = @parser.parse("# [foo, bar]#")
      result = @parser.parse("# { :foo => bar }#")

      # leading whitespace is obligatory
      expect { @parser.parse('#1 #') }.to raise_error(Walrat::ParseError)
      expect { @parser.parse('#foo; bar #') }.to raise_error(Walrat::ParseError)

      # explicit end marker is required
      expect { @parser.parse('# 1') }.to raise_error(Walrat::ParseError)
      expect { @parser.parse('# foo; bar') }.to raise_error(Walrat::ParseError)
    end

    it 'should be able to parse the "slurp" directive' do
      # basic case
      result = @parser.parse("hello #slurp\nworld")
      expect(result[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[0].lexeme).to eq('hello ')
      expect(result[1]).to be_kind_of(Walrus::Grammar::SlurpDirective)
      expect(result[2]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[2].lexeme).to eq('world')

      # must be the last thing on the line (no comments)
      expect { @parser.parse("hello #slurp ## my comment...\nworld") }.to raise_error(Walrat::ParseError)

      # but intervening whitespace is ok
      result = @parser.parse("hello #slurp     \nworld")
      expect(result[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[0].lexeme).to eq('hello ')
      expect(result[1]).to be_kind_of(Walrus::Grammar::SlurpDirective)
      expect(result[2]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[2].lexeme).to eq('world')

      # should only slurp one newline, not multiple newlines
      result = @parser.parse("hello #slurp\n\n\nworld")       # three newlines
      expect(result[0]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[0].lexeme).to eq('hello ')
      expect(result[1]).to be_kind_of(Walrus::Grammar::SlurpDirective)
      expect(result[2]).to be_kind_of(Walrus::Grammar::RawText)
      expect(result[2].lexeme).to eq("\n\nworld")                  # one newline slurped, two left
    end

    it 'should be able to parse the "super" directive with parentheses' do
      # super with empty params
      result = @parser.parse('#super()')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to eq([])

      # same with intervening whitespace
      result = @parser.parse('#super ()')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to eq([])

      # super with one param
      result = @parser.parse('#super("foo")')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params.lexeme).to eq('foo')
      expect(result.params.to_s).to eq('foo')

      # same with intervening whitespace
      result = @parser.parse('#super ("foo")')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params.lexeme).to eq('foo')
      expect(result.params.to_s).to eq('foo')

      # super with two params
      result = @parser.parse('#super("foo", "bar")')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to be_kind_of(Array)
      expect(result.params[0]).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params[0].lexeme).to eq('foo')
      expect(result.params[0].to_s).to eq('foo')
      expect(result.params[1]).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params[1].lexeme).to eq('bar')
      expect(result.params[1].to_s).to eq('bar')

      # same with intervening whitespace
      result = @parser.parse('#super ("foo", "bar")')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to be_kind_of(Array)
      expect(result.params[0]).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params[0].lexeme).to eq('foo')
      expect(result.params[0].to_s).to eq('foo')
      expect(result.params[1]).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params[1].lexeme).to eq('bar')
      expect(result.params[1].to_s).to eq('bar')
    end

    it 'should be able to parse the "super" directive without parentheses' do
      # super with no params
      result = @parser.parse('#super')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to eq([])

      # super with one param
      result = @parser.parse('#super "foo"')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params.lexeme).to eq('foo')
      expect(result.params.to_s).to eq('foo')

      # super with two params
      result = @parser.parse('#super "foo", "bar"')
      expect(result).to be_kind_of(Walrus::Grammar::SuperDirective)
      expect(result.params).to be_kind_of(Array)
      expect(result.params[0]).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params[0].lexeme).to eq('foo')
      expect(result.params[0].to_s).to eq('foo')
      expect(result.params[1]).to be_kind_of(Walrus::Grammar::DoubleQuotedStringLiteral)
      expect(result.params[1].lexeme).to eq('bar')
      expect(result.params[1].to_s).to eq('bar')

    end

    it 'parse results should contain information about their location in the original source (line and column start/end)' do
      # simple raw text
      result = @parser.parse('hello world')
      expect(result.line_start).to    eq(0)  # where the node starts
      expect(result.column_start).to  eq(0)  # where the node starts
      expect(result.line_end).to      eq(0)  # how far the parser got
      expect(result.column_end).to    eq(11) # how far the parser got

      # super with two params
      result = @parser.parse('#super "foo", "bar"')
      expect(result.line_start).to              eq(0)
      expect(result.column_start).to            eq(0)
      expect(result.line_end).to                eq(0)
      expect(result.column_end).to              eq(19)
      expect(result.params.line_start).to       eq(0)
#      result.params.column_start.should     == 7 # get 0
      expect(result.params.line_end).to         eq(0)
      expect(result.params.column_end).to       eq(19)
      expect(result.params[0].line_start).to    eq(0)
      expect(result.params[0].column_start).to  eq(7)
      expect(result.params[0].line_end).to      eq(0)
      expect(result.params[0].column_end).to    eq(12)
      expect(result.params[1].line_start).to    eq(0)
#      result.params[1].column_start.should  == 14 # get 12
      expect(result.params[1].line_end).to      eq(0)
      expect(result.params[1].column_end).to    eq(19)
    end

    it 'ParseErrors should contain information about the location of the problem' do
      # error at beginning of string (unknown directive)
      begin
        @parser.parse('#sooper')
      rescue Walrat::ParseError => e
        exception = e
      end
      expect(exception.line_start).to     eq(0)
      expect(exception.column_start).to   eq(0)
      expect(exception.line_end).to       eq(0)
      expect(exception.column_end).to     eq(0)

      # error on second line (unknown directive)
      begin
        @parser.parse("## a comment\n#sooper")
      rescue Walrat::ParseError => e
        exception = e
      end
      expect(exception.line_start).to     eq(0)
      expect(exception.column_start).to   eq(0)
      expect(exception.line_end).to       eq(1)
      expect(exception.column_end).to     eq(0)

      # error at end of second line (missing closing bracket)
      begin
        @parser.parse("## a comment\n#super (1, 2")
      rescue Walrat::ParseError => e
        exception = e
      end
      expect(exception.line_start).to     eq(0)
      expect(exception.column_start).to   eq(0)
      expect(exception.line_end).to       eq(1)
#      exception.column_end.should     == 12 # returns 0, which is almost right... but we want the rightmost coordinate, not the beginning of the busted directive
      # here the error was returned at line 1, column 0 (the very beginning of the #super directive)
      # but we really would have preferred it to be reported at column 12 (the missing closing bracket)
      # to get to the rightmost point the parser will have had to follow this path:
      # - try to scan a directive
      # - try to scan a super directive
      # - try to scan a parameter list
      # - try to scan a paremeter etc
    end

    it 'produced AST nodes should contain information about their location in the source file'
  end
end # module Walrus
