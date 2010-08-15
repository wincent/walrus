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

require 'walrat'

module Walrat
  class StringParslet < Parslet
    attr_reader :hash

    def initialize string
      raise ArgumentError if string.nil?
      self.expected_string = string
    end

    def parse string, options = {}
      raise ArgumentError if string.nil?
      chars         = StringEnumerator.new string
      parsed        = StringResult.new
      parsed.start  = [options[:line_start], options[:column_start]]
      parsed.end    = parsed.start
      expected_string.each_char do |expected_char|
        actual_char = chars.next
        if actual_char.nil?
          raise ParseError.new('unexpected end-of-string (expected "%s") while parsing "%s"' %
                               [ expected_char, expected_string ],
                               :line_end    => parsed.line_end,
                               :column_end  => parsed.column_end)
        elsif actual_char != expected_char
          raise ParseError.new('unexpected character "%s" (expected "%s") while parsing "%s"' %
                               [ actual_char, expected_char, expected_string],
                               :line_end    => parsed.line_end,
                               :column_end  => parsed.column_end)
        else
          if actual_char == "\r" or
            (actual_char == "\n" and chars.last != "\r")  # catches Mac, Windows and UNIX end-of-line markers
            parsed.column_end = 0
            parsed.line_end   = parsed.line_end + 1
          elsif actual_char != "\n"                     # \n is ignored if it is preceded by an \r (already counted above)
            parsed.column_end = parsed.column_end + 1   # everything else gets counted
          end
          parsed << actual_char
        end
      end
      parsed.source_text = parsed.to_s.clone
      parsed
    end

    def eql?(other)
      other.instance_of? StringParslet and
        other.expected_string == @expected_string
    end

  protected

    # For equality comparisons.
    attr_reader :expected_string

  private

    def expected_string=(string)
      @expected_string = (string.clone rescue string)
      update_hash
    end

    def update_hash
      # fixed offset to avoid collisions with @parseable objects
      @hash = @expected_string.hash + 20
    end
  end # class StringParslet
end # module Walrat
