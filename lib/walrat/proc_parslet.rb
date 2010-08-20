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
  class ProcParslet < Parslet
    attr_reader :hash

    def initialize proc
      raise ArgumentError, 'nil proc' if proc.nil?
      self.expected_proc = proc
    end

    def parse string, options = {}
      raise ArgumentError, 'nil string' if string.nil?
      @expected_proc.call string, options
    end

    def eql?(other)
      other.instance_of? ProcParslet and other.expected_proc == @expected_proc
    end

  protected

    # For equality comparisons.
    attr_reader :expected_proc

  private

    def expected_proc=(proc)
      @expected_proc = (proc.clone rescue proc)
      update_hash
    end

    def update_hash
      # fixed offset to avoid collisions with @parseable objects
      @hash = @expected_proc.hash + 105
    end
  end # class ProcParslet
end # module Walrat
