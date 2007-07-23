# Copyright 2007 Wincent Colaiuta
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
gem 'RedCloth', '= 3.0.4'; require 'redcloth'

# WalrusCloth is a RedCloth subclass that makes minimal modifications for ease of use with Walrus. Specifically, it makes two changes:
#
#   1. The hash or pound character (#) no longer indicates an ordered list; the backtick (`) character is used instead.
#   2. Only Textile rules are used by default, instead of Textile and Markdown.
#
# These changes are made because the hash character already has special meaning in Walrus as a directive marker. Textile is preferred over Markdown because it uses the hash character less extensively (in Markdown it is used as a heading indicator) and does not allow the backslash to be used as an escape marker (which again clashes with Walrus). Without these modifications it would be difficult to use RedCloth as a pre- or post-processor for Walrus templates because many characters would have to be specially escaped. This is particularly the case for the Walrus documentation itself where the documentation includes a lot of literal hash characters.
#
# I considered a number of possible workarounds to the problem, including making a fork of RedCloth. This fork basically consisted of a clean export of the latest RedCloth release with a project-wide replacement of "WalrusCloth" for "RedCloth" and "walruscloth" for "redcloth"; file names were also changed accordingly. Then the regular expressions that define Textile lists were modified. The benefit of this method was that there was no possibility of clashes with any installed version of RedCloth, but it was decidedly inelegant and the changes broke the RedCloth tests.
#
# In the end I decided to subclass RedCloth and override the list-detection regular expressions dynamically. This is somewhat cleaner and easier to maintain although it is still not a perfect solution (see limitations below). It's because of these limitations, together with the fact that I don't want to introduce a dependency on a third-party gem, that WalrusCloth is in the "contrib" subdirectory rather than in the Walrus core.
#
# Usage
# =====
#
#   require 'walrus/contrib/walruscloth'
#   WalrusCloth.new("` hello\n` world").to_html # note the space between the backtick and the list item content
#   # => "<ul>\n\t<li>hello</li>\n\t\t<li>world</li>\n\t</ul>"
#
# Limitations
# ===========
#
# * Fragility: This technique could break for any future release of RedCloth if the way in which list-detection is implemented is changed.
# * Threading: Because this technique changes constants in the RedCloth namespace (albeit temporarily) it is not necessarily very "thread-friendly" if two threads are concurrently trying to use RedCloth and WalrusCloth concurrently. The only way to avoid this issues would be to reimplement the block_textile_lists entirely and that would again be a fragility consideration and a maintenance burden.
# * Warnings: This technique temporarily overrides constants and then restores them to their initial values; this would normally cause "already initialized constant" warnings but they are suppressed here by temporarily altering the $VERBOSE global variable, which is not very elegant.
# * Imparity: Given that this is only a partial override it is possible that some edge and corner cases will fail: for example, inspection of the RedCloth code indicates that it may be necessary to override the "blocks" method (and possibly others) to achieve total parity.
#
class WalrusCloth < RedCloth
  
  def to_html(*rules)
    rules = :textile if rules.empty?
    begin
      old_lists_re          = RedCloth::LISTS_RE            # save original values
      old_lists_content_re  = RedCloth::LISTS_CONTENT_RE
      silently do                                           # override
        RedCloth::const_set('LISTS_RE', /^([`*]+?#{RedCloth::C} .*?)$(?![^`*])/m)
        RedCloth::const_set('LISTS_CONTENT_RE', /^([`*]+)(#{RedCloth::A}#{RedCloth::C}) (.*)$/m)
      end      
      super rules                                           # process
    ensure                                                  # restore original values
      silently do
        RedCloth::const_set('LISTS_RE', old_lists_re)
        RedCloth::const_set('LISTS_CONTENT_RE', old_lists_content_re)
      end
    end
  end
  
  # "lT" presumably stands for "list type" (ordered or unordered)
  def lT( text ) 
    #text =~ /\#$/ ? 'o' : 'u'
    text =~ /`$/ ? 'o' : 'u'
  end
  
  def hard_break( text )
    #text.gsub!( /(.)\n(?!\Z| *([#*=]+(\s|$)|[{|]))/, "\\1<br />" ) if hard_breaks
    text.gsub!( /(.)\n(?!\Z| *([`*=]+(\s|$)|[{|]))/, "\\1<br />" ) if hard_breaks
  end
  
private
  
  # Nasty hack to prevent Ruby from emitting "already initialized constant" warnings when overriding constants.
  # Sets $VERBOSE to nil, executes the passed block, then restores $VERBOSE to its previous state.
  def silently &block
    begin
      verbose = $VERBOSE; $VERBOSE = nil  # save
      yield
    ensure
      $VERBOSE = verbose                  # restore
    end
  end
  
end # WalrusCloth
