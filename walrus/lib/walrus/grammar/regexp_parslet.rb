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
# $Id: regexp_parslet.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

module Walrus
  class Grammar
    
    class RegexpParslet < Parslet
      
      attr_reader :hash
      
      def initialize(regexp)
        raise ArgumentError if regexp.nil?
        self.expected_regexp = /\A#{regexp}/ # for efficiency, anchor all regexps to the start of the string
      end
      
      def parse(string, options = {})
        raise ArgumentError if string.nil?
        if (string =~ @expected_regexp)
          wrapper = MatchDataWrapper.new($~)
          match   = $~[0]
          
          if (line_count = match.scan(/\r\n|\r|\n/).length) != 0        # count number of newlines in match
            column_end    = match.jlength - match.jrindex(/\r|\n/) - 1  # calculate characters on last line
          else                                                          # no newlines in match
            column_end    = match.jlength + (options[:column_start] || 0)
          end
          
          wrapper.start       = [options[:line_start], options[:column_start]]
          wrapper.end         = [wrapper.line_start + line_count, column_end]
          wrapper.source_text = match.to_s.clone
          wrapper
        else
          raise ParseError.new('non-matching characters "%s" while parsing regular expression "%s"' % [string, @expected_regexp.inspect],
                               :line_end    => (options[:line_start] || 0), :column_end    => (options[:column_start] || 0))
        end
      end
      
      def eql?(other)
        other.instance_of? RegexpParslet and other.expected_regexp == @expected_regexp
      end
      
      def inspect
        '#<%s:0x%x @expected_regexp=%s>' % [self.class.to_s, self.object_id, @expected_regexp.inspect]
      end
      
    protected
      
      # For equality comparisons.
      attr_reader :expected_regexp
      
    private
      
      def expected_regexp=(regexp)
        @expected_regexp = ( regexp.clone rescue regexp )
        update_hash
      end
      
      def update_hash
        @hash = @expected_regexp.hash + 15 # fixed offset to avoid collisions with @parseable objects
      end
      
    end # class RegexpParslet
    
  end # class Grammar
end # module Walrus

