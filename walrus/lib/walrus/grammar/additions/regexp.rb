# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: regexp.rb 154 2007-03-26 19:03:21Z wincent $

require 'walrus'

class Regexp
  
  require 'walrus/grammar/parslet_combining'
  include Walrus::Grammar::ParsletCombining
  
  # Returns a RegexpParslet based on the receiver
  def to_parseable
    Walrus::Grammar::RegexpParslet.new(self)
  end
  
end # class Regexp
