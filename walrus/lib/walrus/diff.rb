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
# $Id: diff.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'
require 'open3'
require 'pathname'
require 'tempfile'

# Simple wrapper for diff(1).
class Diff
  
  def initialize(left, right)
    raise ArgumentError.new('left may not be nil') unless left
    raise ArgumentError.new('right may not be nil') unless right
    
    # keep a copy of the parameters (used by the diff method)
    @left   = left.clone
    @right  = right.clone
    
    if left.kind_of? Pathname and right.kind_of? Pathname
      @output = self.compare_pathname_with_pathname(left, right)
    elsif left.kind_of? String and right.kind_of? Pathname
      @output = self.compare_string_with_pathname(left, right)
    elsif left.kind_of? Pathname and right.kind_of? String
      @output = self.compare_pathname_with_string(left, right)
    elsif left.kind_of? String and right.kind_of? String
      @output = self.compare_string_with_string(left, right)
    else
      raise ArgumentError.new('unsupported argument types (%s, %s)' % [left.class.to_s, right.class.to_s])
    end
    
  end
  
  def compare_pathname_with_pathname(left, right)
    self.diff(left.realpath, right.realpath)
  end
  
  def compare_string_with_pathname(left, right)
    # will pipe left in over standard input
    self.diff('-', right.realpath)
  end
  
  def compare_pathname_with_string(left, right)
    # will pipe right in over standard input
    self.diff(left.realpath, '-')
  end
  
  # This is the least secure comparison method because it requires the creation of a temporary file and Ruby's builtin Tempfile class is not secure.
  def compare_string_with_string(left, right)
    # incorporate a psuedo-random component to make race conditions more difficult to exploit
    tempfile = Tempfile.new('walrus-%s' % rand(100000).to_s)
    tempfile.unlink  # shut the race condition vulnerability window as soon as possible
    tempfile.write(left)
    tempfile.close
    self.diff(tempfile.path, "-")
  end
  
  # Actually runs diff(1) with the supplied arguments (pathnames). One but not both of the arguments may be "-" to indicate the standard input.
  def self.diff(left, right)
    raise ArgumentError.new('left may not be ni') unless left
    raise ArgumentError.new('right may not be nil') unless right
    raise ArgumentError.new('only one parameter may be "-"') if left == '-' and right == '-'
    
    # no shell involved, so no need to escape shell metacharacters
    Open3.popen3('diff', '-u', left, right) do |stdin, stdout, stderr|
      if left == '-'
        stdin.write(@left)
      elsif right == '-'
        stdin.write(@right)
      end
      stdin.close_write
      
      # TODO: decide what to do with stderr output (if any)
      stderr.read
      return stdout.read
    end
    
  end
  
  def to_s
    @output
  end
  
end
