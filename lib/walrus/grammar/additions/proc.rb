# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

class Proc
  
  include Walrus::Grammar::ParsletCombining
  
  # Returns a ProcParslet based on the receiver
  def to_parseable
    Walrus::Grammar::ProcParslet.new(self)
  end
  
end # class Proc
