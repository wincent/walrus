# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'

class Array
  
  include Walrus::Grammar::LocationTracking
  include Walrus::Grammar::OmissionData
  
end # class Array
