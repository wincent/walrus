# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: spec_helper.rb 193 2007-07-20 12:56:07Z wincent $

# Individual spec files that require this helper file can be run individually from the commandline.

require 'pathname'
require 'rubygems'
require 'spec'

module Walrus
  module SpecHelper
    
    if not const_defined? 'LIBDIR'
      # will append the local "lib" and "ext" directories to search path if not already present
      base    = File.join(File.dirname(__FILE__), '..')
      LIBDIR  = Pathname.new(File.join(base, 'lib')).realpath
      EXTDIR  = Pathname.new(File.join(base, 'ext')).realpath
      TOOL    = Pathname.new(File.join(base, 'bin', 'walrus')).realpath
      
      # normalize all paths in the load path
      normalized = $:.collect { |path| Pathname.new(path).realpath rescue path }
      
      # only add the directories if they do not appear to be present already
      [LIBDIR, EXTDIR].each { |path| $:.push(path) unless normalized.include?(path) }    
    end
    
  end # module SpecHelper
end # module Walrus

require 'walrus'
