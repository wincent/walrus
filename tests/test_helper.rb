# Copyright 2007 Wincent Colaiuta
# $Id$

# Individual test files that require this helper file can be run individually from the commandline.

require 'test/unit'
require 'pathname'

# TODO: command-line option to test against installed copy of Walrus

module Walrus
  
  module TestHelper
    
    # will append the local libs directory to search path if not already present
    parent = Pathname.new(File.join(File.dirname(__FILE__), '..', 'lib')).realpath
    
    # normalize all paths ("rescue" because "realpath" will raise if lstat(2) fails for the path: non-existent paths, relative paths etc)
    normalized = $:.collect { |path| Pathname.new(path).realpath rescue path }
    
    # only add the parent directory if it does not appear to be present already
    $:.push(parent) if not normalized.include?(parent)
    
  end # module TestHelper
  
end # module Walrus
