# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'walrat'

module Walrus
  autoload :CompileError, 'walrus/compile_error'
  autoload :Compiler,     'walrus/compiler'
  autoload :COPYRIGHT,    'walrus/version'
  autoload :Grammar,      'walrus/grammar'
  autoload :Parser,       'walrus/parser'
  autoload :Template,     'walrus/template'
  autoload :VERSION,      'walrus/version'
end # module Walrus

require 'walrus/additions/string'
