# Copyright 2007 Wincent Colaiuta
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id: parslet_omission_spec.rb 166 2007-04-09 15:04:40Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    describe 'using a Parslet Omission' do
      
      it 'should raise if "parseable" argument is nil' do
        lambda { ParsletOmission.new(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should complain if pass nil string for parsing' do
        lambda { ParsletOmission.new('foo'.to_parseable).parse(nil) }.should raise_error(ArgumentError)
      end
      
      it 'should let parse errors from lower levels fall through' do
        lambda { ParsletOmission.new('foo'.to_parseable).parse('bar') }.should raise_error(ParseError)
      end
      
      it 'should indicate parse errors with a SubstringSkippedException' do
        lambda { ParsletOmission.new('foo'.to_parseable).parse('foo') }.should raise_error(SkippedSubstringException)
      end
      
      it 'the raised SubstringSkippedException should include the parsed substring' do
        begin
          ParsletOmission.new('foo'.to_parseable).parse('foobar')
        rescue SkippedSubstringException => e
          substring = e.to_s
        end
        substring.should == 'foo'
      end
      
      it 'the parsed substring should be an empty string in the case of a zero-width parse success at a lower level' do
        begin
          ParsletOmission.new('foo'.optional).parse('bar') # a contrived example
        rescue SkippedSubstringException => e
          substring = e.to_s
        end
        substring.should == ''
      end
      
      it 'should be able to compare for equality' do
        ParsletOmission.new('foo').should eql(ParsletOmission.new('foo'))
        ParsletOmission.new('foo').should_not eql(ParsletOmission.new('bar'))
      end
      
    end
    
  end # class Grammar
end # module Walrus
