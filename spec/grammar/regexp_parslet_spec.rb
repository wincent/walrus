# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'using a regexp parslet' do
      
      setup do
        @parslet = RegexpParslet.new(/[a-zA-Z_][a-zA-Z0-9_]*/)
      end
      
      specify 'should raise an ArgumentError if initialized with nil' do
        lambda { RegexpParslet.new(nil) }.should_raise ArgumentError
      end
      
      specify 'parse should succeed if the input string matches' do
        lambda { @parslet.parse('an_identifier') }.should_not_raise
        lambda { @parslet.parse('An_Identifier') }.should_not_raise
        lambda { @parslet.parse('AN_IDENTIFIER') }.should_not_raise
        lambda { @parslet.parse('an_identifier1') }.should_not_raise
        lambda { @parslet.parse('An_Identifier1') }.should_not_raise
        lambda { @parslet.parse('AN_IDENTIFIER1') }.should_not_raise
        lambda { @parslet.parse('a') }.should_not_raise
        lambda { @parslet.parse('A') }.should_not_raise
        lambda { @parslet.parse('a9') }.should_not_raise
        lambda { @parslet.parse('A9') }.should_not_raise
        lambda { @parslet.parse('_identifier') }.should_not_raise
        lambda { @parslet.parse('_Identifier') }.should_not_raise
        lambda { @parslet.parse('_IDENTIFIER') }.should_not_raise
        lambda { @parslet.parse('_9Identifier') }.should_not_raise
        lambda { @parslet.parse('_') }.should_not_raise
      end
      
      specify 'parse should succeed if the input string matches, even if it continues after the match' do
        lambda { @parslet.parse('an_identifier, more') }.should_not_raise
        lambda { @parslet.parse('An_Identifier, more') }.should_not_raise
        lambda { @parslet.parse('AN_IDENTIFIER, more') }.should_not_raise
        lambda { @parslet.parse('an_identifier1, more') }.should_not_raise
        lambda { @parslet.parse('An_Identifier1, more') }.should_not_raise
        lambda { @parslet.parse('AN_IDENTIFIER1, more') }.should_not_raise
        lambda { @parslet.parse('a, more') }.should_not_raise
        lambda { @parslet.parse('A, more') }.should_not_raise
        lambda { @parslet.parse('a9, more') }.should_not_raise
        lambda { @parslet.parse('A9, more') }.should_not_raise
        lambda { @parslet.parse('_identifier, more') }.should_not_raise
        lambda { @parslet.parse('_Identifier, more') }.should_not_raise
        lambda { @parslet.parse('_IDENTIFIER, more') }.should_not_raise
        lambda { @parslet.parse('_9Identifier, more') }.should_not_raise
        lambda { @parslet.parse('_, more') }.should_not_raise
      end
      
      specify 'parse should return a MatchDataWrapper object' do
        @parslet.parse('an_identifier').should == 'an_identifier'
        @parslet.parse('an_identifier, more').should == 'an_identifier'
      end
      
      specify 'parse should raise an ArgumentError if passed nil' do
        lambda { @parslet.parse(nil) }.should_raise ArgumentError
      end
      
      specify 'parse should raise a ParseError if the input string does not match' do
        lambda { @parslet.parse('9') }.should_raise ParseError               # a number is not a valid identifier
        lambda { @parslet.parse('9fff') }.should_raise ParseError            # identifiers must not start with numbers
        lambda { @parslet.parse(' identifier') }.should_raise ParseError     # note the leading whitespace
        lambda { @parslet.parse('') }.should_raise ParseError                # empty strings can't match
      end
      
      specify 'should be able to compare parslets for equality' do
        /foo/.to_parseable.should_eql /foo/.to_parseable        # equal
        /foo/.to_parseable.should_not_eql /bar/.to_parseable    # different
        /foo/.to_parseable.should_not_eql /Foo/.to_parseable    # differing only in case
        /foo/.to_parseable.should_not_eql 'foo'                 # totally different classes
      end
      
      specify 'should accurately pack line and column offsets into whatever gets returned from "parse"' do
        
        # single word
        parslet = /.+/m.to_parseable
        result = parslet.parse('hello')
        result.line_offset.should == 0
        result.column_offset.should == 5
        
        # single word with newline at end (UNIX style)
        result = parslet.parse("hello\n")
        result.line_offset.should == 1
        result.column_offset.should == 0
        
        # single word with newline at end (Classic Mac style)
        result = parslet.parse("hello\r")
        result.line_offset.should == 1
        result.column_offset.should == 0
        
        # single word with newline at end (Windows style)
        result = parslet.parse("hello\r\n")
        result.line_offset.should == 1
        result.column_offset.should == 0
        
        # two lines (UNIX style)
        result = parslet.parse("hello\nworld")
        result.line_offset.should == 1
        result.column_offset.should == 5
        
        # two lines (Classic Mac style)
        result = parslet.parse("hello\rworld")
        result.line_offset.should == 1
        result.column_offset.should == 5
        
        # two lines (Windows style)
        result = parslet.parse("hello\r\nworld")
        result.line_offset.should == 1
        result.column_offset.should == 5
        
      end
      
      # in the case of RegexpParslets, the "last successfully scanned position" is always 0, 0
      specify 'line and column offset should reflect last succesfully scanned position prior to failure' do
        
        # fail right at start
        parslet = /hello\r\nworld/.to_parseable
        begin
          parslet.parse('foobar')
        rescue ParseError => e
          exception = e
        end
        exception.line_offset.should == 0
        exception.column_offset.should == 0
        
        # fail after 1 character
        begin
          parslet.parse('hfoobar')
        rescue ParseError => e
          exception = e
        end
        exception.line_offset.should == 0
        exception.column_offset.should == 0
        
        # fail after end-of-line
        begin
          parslet.parse("hello\r\nfoobar")
        rescue ParseError => e
          exception = e
        end
        exception.line_offset.should == 0
        exception.column_offset.should == 0
        
      end
      
    end
    
    context 'chaining two regexp parslets together' do
      
      specify 'parslets should work in specified order' do
        parslet = RegexpParslet.new(/foo.\d/) & RegexpParslet.new(/bar.\d/)
        parslet.parse('foo_1bar_2').should == ['foo_1', 'bar_2']
      end
      
      # Parser Expression Grammars match greedily
      specify 'parslets should match greedily' do
        
        # the first parslet should gobble up the entire string, preventing the second parslet from succeeding
        parslet = RegexpParslet.new(/foo.+\d/) & RegexpParslet.new(/bar.+\d/)
        lambda { parslet.parse('foo_1bar_2') }.should_raise ParseError
        
      end
      
    end
    
    context 'alternating two regexp parslets' do
      
      specify 'either parslet should apply to generate a match' do
        parslet = RegexpParslet.new(/\d+/) | RegexpParslet.new(/[A-Z]+/)
        parslet.parse('ABC').should == 'ABC'
        parslet.parse('123').should == '123'
      end
      
      specify 'should fail if no parslet generates a match' do
        parslet = RegexpParslet.new(/\d+/) | RegexpParslet.new(/[A-Z]+/)
        lambda { parslet.parse('abc') }.should_raise ParseError
      end
      
      specify 'parslets should be tried in left-to-right order' do
        
        # in this case the first parslet should win even though the second one is also a valid match
        parslet = RegexpParslet.new(/(.)(..)/) | RegexpParslet.new(/(..)(.)/)
        match_data = parslet.parse('abc').match_data
        match_data[1].should == 'a'
        match_data[2].should == 'bc'
        
        # here we swap the order; again the first parslet should win
        parslet = RegexpParslet.new(/(..)(.)/) | RegexpParslet.new(/(.)(..)/)
        match_data = parslet.parse('abc').match_data
        match_data[1].should == 'ab'
        match_data[2].should == 'c'
        
      end
      
    end
    
    context 'chaining three regexp parslets' do
      
      specify 'parslets should work in specified order' do
        parslet = RegexpParslet.new(/foo.\d/) & RegexpParslet.new(/bar.\d/) & RegexpParslet.new(/.../)
        parslet.parse('foo_1bar_2ABC').should == ['foo_1', 'bar_2', 'ABC']        
      end
      
    end
    
    context 'alternating three regexp parslets' do
      
      specify 'any parslet should apply to generate a match' do
        parslet = RegexpParslet.new(/\d+/) | RegexpParslet.new(/[A-Z]+/) | RegexpParslet.new(/[a-z]+/)
        parslet.parse('ABC').should == 'ABC'
        parslet.parse('123').should == '123'
        parslet.parse('abc').should == 'abc'
      end
      
      specify 'should fail if no parslet generates a match' do
        parslet = RegexpParslet.new(/\d+/) | RegexpParslet.new(/[A-Z]+/) | RegexpParslet.new(/[a-z]+/)
        lambda { parslet.parse(':::') }.should_raise ParseError
      end
      
      specify 'parslets should be tried in left-to-right order' do
        
        # in this case the first parslet should win even though the others also produce valid matches
        parslet = RegexpParslet.new(/(.)(..)/) | RegexpParslet.new(/(..)(.)/) | RegexpParslet.new(/(...)/)
        match_data = parslet.parse('abc').match_data
        match_data[1].should == 'a'
        match_data[2].should == 'bc'
        
        # here we swap the order; again the first parslet should win
        parslet = RegexpParslet.new(/(..)(.)/) | RegexpParslet.new(/(.)(..)/) | RegexpParslet.new(/(...)/)
        match_data = parslet.parse('abc').match_data
        match_data[1].should == 'ab'
        match_data[2].should == 'c'
        
        # similar test but this time the first parslet can't win (doesn't match)
        parslet = RegexpParslet.new(/foo/) | RegexpParslet.new(/(...)/) | RegexpParslet.new(/(.)(..)/)
        match_data = parslet.parse('abc').match_data
        match_data[1].should == 'abc'
        
      end
      
    end
    
    context 'combining chaining and alternation' do
      
      specify 'chaining should having higher precedence than alternation' do
        
        # equivalent to /foo/ | ( /bar/ & /abc/ )
        parslet = RegexpParslet.new(/foo/) | RegexpParslet.new(/bar/) & RegexpParslet.new(/abc/)
        parslet.parse('foo').should == 'foo'                                            # succeed on first choice
        parslet.parse('barabc').should == ['bar', 'abc']                                # succeed on alternate path
        lambda { parslet.parse('bar...') }.should_raise ParseError                      # fail half-way down alternate path
        lambda { parslet.parse('lemon') }.should_raise ParseError                       # fail immediately
        
        # swap the order, now equivalent to: ( /bar/ & /abc/ ) | /foo/
        parslet = RegexpParslet.new(/bar/) & RegexpParslet.new(/abc/) | RegexpParslet.new(/foo/)
        parslet.parse('barabc').should == ['bar', 'abc']                                # succeed on first choice
        parslet.parse('foo').should == 'foo'                                            # succeed on alternate path
        lambda { parslet.parse('bar...') }.should_raise ParseError                      # fail half-way down first path
        lambda { parslet.parse('lemon') }.should_raise ParseError                       # fail immediately
        
      end
      
      specify 'should be able to override precedence using parentheses' do
        
        # take first example above and make it ( /foo/ | /bar/ ) & /abc/
        parslet = (RegexpParslet.new(/foo/) | RegexpParslet.new(/bar/)) & RegexpParslet.new(/abc/)
        parslet.parse('fooabc').should == ['foo', 'abc']                                # first choice
        parslet.parse('barabc').should == ['bar', 'abc']                                # second choice
        lambda { parslet.parse('foo...') }.should_raise ParseError                      # fail in second half
        lambda { parslet.parse('bar...') }.should_raise ParseError                      # another way of failing in second half
        lambda { parslet.parse('foo') }.should_raise ParseError                         # another way of failing in second half
        lambda { parslet.parse('bar') }.should_raise ParseError                         # another way of failing in second half
        lambda { parslet.parse('lemon') }.should_raise ParseError                       # fail immediately
        lambda { parslet.parse('abcfoo') }.should_raise ParseError                      # order matters
        
        # take second example above and make it /bar/ & ( /abc/ | /foo/ )
        parslet = RegexpParslet.new(/bar/) & (RegexpParslet.new(/abc/) | RegexpParslet.new(/foo/))
        parslet.parse('barabc').should == ['bar', 'abc']                                # succeed on first choice
        parslet.parse('barfoo').should == ['bar', 'foo']                                # second choice
        lambda { parslet.parse('bar...') }.should_raise ParseError                      # fail in second part
        lambda { parslet.parse('bar') }.should_raise ParseError                         # another way to fail in second part
        lambda { parslet.parse('lemon') }.should_raise ParseError                       # fail immediately
        lambda { parslet.parse('abcbar') }.should_raise ParseError                      # order matters
        
      end
      
      specify 'should be able to include long runs of sequences' do
        
        # A & B & C & D | E
        parslet = RegexpParslet.new(/a/) & RegexpParslet.new(/b/) & RegexpParslet.new(/c/) & RegexpParslet.new(/d/) | RegexpParslet.new(/e/)
        parslet.parse('abcd').should == ['a', 'b', 'c', 'd']
        parslet.parse('e').should == 'e'
        lambda { parslet.parse('f') }.should_raise ParseError
        
      end
      
      specify 'should be able to include long runs of options' do
        
        # A | B | C | D & E
        parslet = RegexpParslet.new(/a/) | RegexpParslet.new(/b/) | RegexpParslet.new(/c/) | RegexpParslet.new(/d/) & RegexpParslet.new(/e/)
        parslet.parse('a').should == 'a'
        parslet.parse('b').should == 'b'
        parslet.parse('c').should == 'c'
        parslet.parse('de').should == ['d', 'e']
        lambda { parslet.parse('f') }.should_raise ParseError
        
      end
      
      specify 'should be able to alternate repeatedly between sequences and choices' do
        
        # A & B | C & D | E
        parslet = RegexpParslet.new(/a/) & RegexpParslet.new(/b/) | RegexpParslet.new(/c/) & RegexpParslet.new(/d/) | RegexpParslet.new(/e/)
        parslet.parse('ab').should == ['a', 'b']
        parslet.parse('cd').should == ['c', 'd']
        parslet.parse('e').should == 'e'
        lambda { parslet.parse('f') }.should_raise ParseError
        
      end
      
      specify 'should be able to combine long runs with alternation' do
        
        # A & B & C | D | E | F & G & H
        parslet = RegexpParslet.new(/a/) & RegexpParslet.new(/b/) & RegexpParslet.new(/c/) | 
                  RegexpParslet.new(/d/) | RegexpParslet.new(/e/) | RegexpParslet.new(/f/) &
                  RegexpParslet.new(/g/) & RegexpParslet.new(/h/)
        parslet.parse('abc').should == ['a', 'b', 'c']
        parslet.parse('d').should == 'd'
        parslet.parse('e').should == 'e'
        parslet.parse('fgh').should == ['f', 'g', 'h']
        lambda { parslet.parse('i') }.should_raise ParseError
        
      end
      
    end
    
  end # class Grammar
end # module Walrus
