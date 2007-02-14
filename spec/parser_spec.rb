# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

require 'walrus/parser'

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
      result.content.should == [] # might be nice to automatically flatten this stuff into a string
      
      # multi-line comment (with content)
      result = @parser.parse('#* hello world *#')
      result.should_be_kind_of WalrusGrammar::MultilineComment
#      result.content.should == ' hello world '     #FAILS
      
      # multi-line comment (spanning multiple lines)
      result = @parser.parse("#* hello\nworld *#")
      result.should_be_kind_of WalrusGrammar::MultilineComment
      
      # multi-line comment (with nested comment)
      result = @parser.parse('#* hello #*world*# *#')
      result.should_be_kind_of WalrusGrammar::MultilineComment
      
      # multi-line comment (with nested comment, spanning multiple lines)
      result = @parser.parse("#* hello\n#* world\n... *# *#")
      result.should_be_kind_of WalrusGrammar::MultilineComment
      
      # multi-line comment (with nested single-line comment)
      result = @parser.parse("#* ##hello\n*#")
      result.should_be_kind_of WalrusGrammar::MultilineComment
      
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
      lambda { @parser.parse('# extends OtherTemplate') }.should_raise Grammar::ParseError
    end
    
    specify 'should be able to parse a directive that takes a single parameter' do
      result = @parser.parse('#extends OtherTemplate')
      result.should_be_kind_of WalrusGrammar::Directive
      result.should_be_kind_of WalrusGrammar::ExtendsDirective
      result.class_name.lexeme.should == 'OtherTemplate'
    end
    
    specify 'should be able to parse a directive with no parameters' do
      # basic test
      
      # TODO: rewrite this test... are there any directives which don't take any parameters now that #end is not parsed separately?
#      result = @parser.parse('#end')
#      result.should_be_kind_of WalrusGrammar::EndDirective
    end
    
    specify 'should be able to follow a directive by a comment on the same line, only if the directive has an explicit termination marker' do
      
      # no intervening whitespace ("extends" directive, takes one parameter)
      result = @parser.parse('#extends OtherTemplate### comment')
      result[0].should_be_kind_of WalrusGrammar::ExtendsDirective
      result[0].class_name.lexeme.should == 'OtherTemplate'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#extends OtherTemplate## comment') }.should_raise Grammar::ParseError
      
      # intervening whitespace (between parameter and trailing comment)
      result = @parser.parse('#extends OtherTemplate           ### comment')
      result[0].should_be_kind_of WalrusGrammar::ExtendsDirective
      result[0].class_name.lexeme.should == 'OtherTemplate'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#extends OtherTemplate           ## comment') }.should_raise Grammar::ParseError
      
      # intervening whitespace (between directive and parameter)
      result = @parser.parse('#extends          OtherTemplate           ### comment')
      result[0].should_be_kind_of WalrusGrammar::ExtendsDirective
      result[0].class_name.lexeme.should == 'OtherTemplate'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#extends          OtherTemplate           ## comment') }.should_raise Grammar::ParseError
      
      # same but with "end" directive (no parameters)
      # TODO: new test with a directive that takes no parameters
#      result = @parser.parse('#end## comment')
#      result[0].should_be_kind_of WalrusGrammar::EndDirective
#      result[0].lexeme.should == '#end'
#      result[1].should_be_kind_of WalrusGrammar::Comment
#      result[1].lexeme.should == ' comment'
      
      # intervening whitespace
#      result = @parser.parse('#end           ## comment')
#      result[0].should_be_kind_of WalrusGrammar::EndDirective
#      result[0].lexeme.should == '#end'
#      result[1].should_be_kind_of WalrusGrammar::Comment
#      result[1].lexeme.should == ' comment'
      
    end
    
    specify 'should be able to span directives across lines by using a line continuation backslash' do
      
      # basic case
      result = @parser.parse("#extends \\\nOtherTemplate")
      result.should_be_kind_of WalrusGrammar::ExtendsDirective
      result.class_name.lexeme.should == 'OtherTemplate'
      
      # should fail if backslash is not the last character on the line
      lambda { @parser.parse("#extends \\ \nOtherTemplate") }.should_raise Grammar::ParseError
      
    end

    specify 'should be able to parse an "import" directive' do
      
      # followed by a newline
      result = @parser.parse("#import OtherTemplate\nhello")
      result[0].should_be_kind_of WalrusGrammar::ImportDirective
      result[0].class_name.lexeme.should == 'OtherTemplate'
      result[1].should_be_kind_of WalrusGrammar::RawText
      result[1].lexeme.should == 'hello' # newline gets eaten
      
      # followed by whitespace
      result = @parser.parse('#import OtherTemplate     ')
      result.should_be_kind_of WalrusGrammar::ImportDirective
      result.class_name.lexeme.should == 'OtherTemplate'
      
      # followed by the end of the input
      result = @parser.parse('#import OtherTemplate')
      result.should_be_kind_of WalrusGrammar::ImportDirective
      result.class_name.lexeme.should == 'OtherTemplate'
      
      # comment with no intervening whitespace
      result = @parser.parse('#import OtherTemplate### comment')
      result[0].should_be_kind_of WalrusGrammar::ImportDirective
      result[0].class_name.lexeme.should == 'OtherTemplate'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#import OtherTemplate## comment') }.should_raise Grammar::ParseError
      
      # intervening whitespace (between parameter and trailing comment)
      result = @parser.parse('#import OtherTemplate           ### comment')
      result[0].should_be_kind_of WalrusGrammar::ImportDirective
      result[0].class_name.lexeme.should == 'OtherTemplate'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#import OtherTemplate           ## comment') }.should_raise Grammar::ParseError
      
      # intervening whitespace (between directive and parameter)
      result = @parser.parse('#import          OtherTemplate           ### comment')
      result[0].should_be_kind_of WalrusGrammar::ImportDirective
      result[0].class_name.lexeme.should == 'OtherTemplate'
      result[1].should_be_kind_of WalrusGrammar::Comment
      result[1].lexeme.should == ' comment'
      
      # counter-example
      lambda { @parser.parse('#import          OtherTemplate           ## comment') }.should_raise Grammar::ParseError
      
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
    
    specify 'should be able to parse the "def" directive' do
      
      # simple case: no parameters
      
      
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
      
    end
    
    specify 'should be able to parse the "set" directive' do
      
      # assign a string literal 
      result = @parser.parse('#set foo = "bar"')
      
      # assign a local variable
      result = @parser.parse('#set foo = bar')
      
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
    
  end
  
end # module Walrus

