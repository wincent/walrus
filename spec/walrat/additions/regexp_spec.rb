# Copyright 2007-2010 Wincent Colaiuta
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

require File.expand_path('../../spec_helper', File.dirname(__FILE__))

# For more detailed specification of the RegexpParslet behaviour see
# regexp_parslet_spec.rb.
describe 'using shorthand to get RegexpParslets from Regexp instances' do
  context 'chaining two Regexps with the "&" operator' do
    it 'yields a two-element sequence' do
      sequence = /foo/ & /bar/
      sequence.parse('foobar').map { |each| each.to_s }.should == ['foo', 'bar']
    end
  end

  context 'chaining three Regexps with the "&" operator' do
    it 'yields a three-element sequence' do
      sequence = /foo/ & /bar/ & /\.\.\./
      sequence.parse('foobar...').map { |each| each.to_s }.should == ['foo', 'bar', '...']
    end
  end

  context 'alternating two Regexps with the "|" operator' do
    it 'yields a MatchDataWrapper' do
      sequence = /foo/ | /bar/
      sequence.parse('foobar').to_s.should == 'foo'
      sequence.parse('bar...').to_s.should == 'bar'
      expect do
        sequence.parse('no match')
      end.to raise_error(Walrat::ParseError)
    end
  end
end
