# Copyright 2007-2010 Wincent Colaiuta
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

require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Walrus::Compiler do
  before do
    @parser = Walrus::Parser.new
  end

  it 'compiles a comment followed by raw text' do
    # note that trailing newline is eaten when the comment is the only thing on
    # the line
    eval @parser.compile "## hello world\nhere's some raw text",
      :class_name => :CompilerSpecAlpha
    Walrus::Grammar::CompilerSpecAlpha.new.fill.should == "here's some raw text"
  end

  it 'compiles raw text followed by a comment' do
    # on the same line (note that trailing newline is not eaten)
    eval @parser.compile "here's some raw text## hello world\n",
      :class_name => :CompilerSpecBeta
    Walrus::Grammar::CompilerSpecBeta.new.fill.should == "here's some raw text\n"

    # on two separate lines (note that second trailing newline gets eaten)
    eval @parser.compile "here's some raw text\n## hello world\n",
      :class_name => :CompilerSpecDelta
    Walrus::Grammar::CompilerSpecDelta.new.fill.should == "here's some raw text\n"

    # same but with no trailing newline
    eval @parser.compile "here's some raw text\n## hello world",
      :class_name => :CompilerSpecGamma
    Walrus::Grammar::CompilerSpecGamma.new.fill.should == "here's some raw text\n"
  end
end
