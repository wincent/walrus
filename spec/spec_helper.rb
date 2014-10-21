# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'pathname'
require 'rspec'

module Walrus
  module SpecHelper
    # will append the local "lib" directory to search path if not
    # already present
    SPEC    = Pathname.new(__FILE__).dirname.realpath
    BASE    = (SPEC + '..').realpath
    LIBDIR  = (BASE + 'lib').realpath
    TOOL    = (BASE + 'bin' + 'walrus').realpath

    # normalize all paths in the load path
    normalized = $:.map { |path| Pathname.new(path).realpath rescue path }

    # only add the directory if it does not appear to be present already
    $:.unshift(LIBDIR) unless normalized.include?(LIBDIR)
  end # module SpecHelper
end # module Walrus

require 'walrus'
