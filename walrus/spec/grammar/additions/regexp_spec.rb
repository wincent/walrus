# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: regexp_spec.rb 166 2007-04-09 15:04:40Z wincent $

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

module Walrus
  class Grammar
    
    # For more detailed specification of the RegexpParslet behaviour see regexp_parslet_spec.rb.
    describe 'using shorthand to get RegexpParslets from Regexp instances' do
      
      it 'chaining two Regexps with the "&" operator should yield a two-element sequence' do
        sequence = /foo/ & /bar/
        sequence.parse('foobar').collect { |each| each.to_s }.should == ['foo', 'bar']
      end
      
      it 'chaining three Regexps with the "&" operator should yield a three-element sequence' do
        sequence = /foo/ & /bar/ & /\.\.\./
        sequence.parse('foobar...').collect { |each| each.to_s }.should == ['foo', 'bar', '...']
      end
      
      it 'alternating two Regexps with the "|" operator should yield a MatchDataWrapper' do
        sequence = /foo/ | /bar/
        sequence.parse('foobar').to_s.should == 'foo'
        sequence.parse('bar...').to_s.should == 'bar'
        lambda { sequence.parse('no match') }.should raise_error(ParseError)
      end
      
    end
    
  end # class Grammar
end # module Walrus