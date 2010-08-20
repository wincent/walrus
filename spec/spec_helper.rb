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

require 'pathname'
require 'rubygems'
require 'spec'

module Walrus
  module SpecHelper
    # will append the local "lib" and "ext" directories to search path if not
    # already present
    base    = File.expand_path '..', File.dirname(__FILE__)
    LIBDIR  = Pathname.new(File.join base, 'lib').realpath
    EXTDIR  = Pathname.new(File.join base, 'ext').realpath
    TOOL    = Pathname.new(File.join base, 'bin', 'walrus').realpath

    # normalize all paths in the load path
    normalized = $:.collect { |path| Pathname.new(path).realpath rescue path }

    # only add the directories if they do not appear to be present already
    [LIBDIR, EXTDIR].each do |path|
      $:.push(path) unless normalized.include?(path)
    end
  end # module SpecHelper
end # module Walrus

require 'walrus'
