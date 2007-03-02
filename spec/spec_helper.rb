# Copyright 2007 Wincent Colaiuta
# $Id$

# Individual spec files that require this helper file can be run individually from the commandline.

require 'pathname'
require 'rubygems'
require 'spec'

module Walrus
  module SpecHelper
    
    if not const_defined? "LIBDIR"
      # will append the local "lib" and "ext" directories to search path if not already present
      LIBDIR  = Pathname.new(File.join(File.dirname(__FILE__), '..', 'lib')).realpath
      EXTDIR  = Pathname.new(File.join(LIBDIR, '..', 'ext')).realpath
      
      # normalize all paths in the load path (use "rescue" because "realpath" will raise if lstat(2) fails for the path: non-existent paths, relative paths etc)
      normalized = $:.collect { |path| Pathname.new(path).realpath rescue path }
      
      # only add the directories if they do not appear to be present already
      [LIBDIR, EXTDIR].each { |path| $:.push(path) unless normalized.include?(path) }    
    end
    
  end # module SpecHelper
end # module Walrus

require 'walrus'
