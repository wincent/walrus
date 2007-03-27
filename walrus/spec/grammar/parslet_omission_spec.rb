# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    context 'using a Parslet Omission' do
      
      specify 'should raise if "parseable" argument is nil' do
        lambda { ParsletOmission.new(nil) }.should_raise ArgumentError
      end
      
      specify 'should complain if pass nil string for parsing' do
        lambda { ParsletOmission.new('foo'.to_parseable).parse(nil) }.should_raise ArgumentError
      end
      
      specify 'should let parse errors from lower levels fall through' do
        lambda { ParsletOmission.new('foo'.to_parseable).parse('bar') }.should_raise ParseError
      end
      
      specify 'should indicate parse errors with a SubstringSkippedException' do
        lambda { ParsletOmission.new('foo'.to_parseable).parse('foo') }.should_raise SkippedSubstringException
      end
      
      specify 'the raised SubstringSkippedException should include the parsed substring' do
        begin
          ParsletOmission.new('foo'.to_parseable).parse('foobar')
        rescue SkippedSubstringException => e
          substring = e.to_s
        end
        substring.should == 'foo'
      end
      
      specify 'the parsed substring should be an empty string in the case of a zero-width parse success at a lower level' do
        begin
          ParsletOmission.new('foo'.optional).parse('bar') # a contrived example
        rescue SkippedSubstringException => e
          substring = e.to_s
        end
        substring.should == ''
      end
      
      specify 'should be able to compare for equality' do
        ParsletOmission.new('foo').should_eql ParsletOmission.new('foo')
        ParsletOmission.new('foo').should_not_eql ParsletOmission.new('bar')
      end
      
    end
    
  end # class Grammar
end # module Walrus
