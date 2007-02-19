# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

class Regexp
  
  require 'walrus/grammar/parslet_combining'
  include Walrus::Grammar::ParsletCombining
  
  # Returns a RegexpParslet based on the receiver
  def to_parseable
    Walrus::Grammar::RegexpParslet.new(self)
  end
  
end # class Regexp
