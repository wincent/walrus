# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id$

require 'walrus'

class Proc
  
  include Walrus::Grammar::ParsletCombining
  
  # Returns a ProcParslet based on the receiver
  def to_parseable
    Walrus::Grammar::ProcParslet.new(self)
  end
  
end # class Proc
