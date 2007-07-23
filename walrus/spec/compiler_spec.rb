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
#
# $Id: compiler_spec.rb 192 2007-05-03 09:27:35Z wincent $

require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'walrus/parser' # ensure that WalrusGrammar is defined before continuing

module Walrus
  
  class WalrusGrammar
    
    describe 'using the Compiler class' do
      
      before(:all) do
        @parser = Parser.new
      end
      
      it 'should be able to compile a comment followed by raw text' do
        
        # note that trailing newline is eaten when the comment is the only thing on the newline
        compiled = @parser.compile("## hello world\nhere's some raw text", :class_name => :CompilerSpecAlpha)
        self.class.module_eval(compiled)
        self.class::Walrus::WalrusGrammar::CompilerSpecAlpha.new.fill.should == "here's some raw text"
        
      end
      
      it 'should be able to compile raw text followed by a comment' do
        
        # on the same line (note that trailing newline is not eaten)
        compiled = @parser.compile("here's some raw text## hello world\n", :class_name => :CompilerSpecBeta)
        self.class.module_eval(compiled)
        self.class::Walrus::WalrusGrammar::CompilerSpecBeta.new.fill.should == "here's some raw text\n"
        
        # on two separate lines (note that second trailing newline gets eaten)
        compiled = @parser.compile("here's some raw text\n## hello world\n", :class_name => :CompilerSpecDelta)
        self.class.module_eval(compiled)
        self.class::Walrus::WalrusGrammar::CompilerSpecDelta.new.fill.should == "here's some raw text\n"
        
        # same but with no trailing newline
        compiled = @parser.compile("here's some raw text\n## hello world", :class_name => :CompilerSpecGamma)
        self.class.module_eval(compiled)
        self.class::Walrus::WalrusGrammar::CompilerSpecGamma.new.fill.should == "here's some raw text\n"
        
      end
      
    end
    
  end
  
end # module Walrus

