# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus/model'

class Def < Model
  
  attr_reader :identifier_string
  
  def initialize(directive)
    super
    raise ArgumentError.new("Nil directive string passed to Def") if directive.string.nil?
    raise ArgumentError.new("Mismatched directive string passed to Def") if directive.directive_string =~ /^def$/i
    raise ArgumentError.new("Nil parameter string passed to Def") if directive.parameter_string.nil?
    raise ArgumentError.new("Invalid identifier string passed to Def") if not directive.parameter_string =~ /\s*[a-zA-Z_][a-zA-Z0-9_]*\s*/
    @identifier_string = $1
  end
  
end
