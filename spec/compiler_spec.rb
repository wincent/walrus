# Copyright 2007-2010 Wincent Colaiuta. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Walrus::Compiler do
  before do
    @parser = Walrus::Parser.new
  end

  it 'compiles a comment followed by raw text' do
    # note that trailing newline is eaten when the comment is the only thing on
    # the line
    Object.class_eval @parser.compile "## hello world\nhere's some raw text",
      :class_name => :CompilerSpecAlpha
    Walrus::Grammar::CompilerSpecAlpha.new.fill.should == "here's some raw text"
  end

  it 'compiles raw text followed by a comment' do
    # on the same line (note that trailing newline is not eaten)
    Object.class_eval @parser.compile "here's some raw text## hello world\n",
      :class_name => :CompilerSpecBeta
    Walrus::Grammar::CompilerSpecBeta.new.fill.should == "here's some raw text\n"

    # on two separate lines (note that second trailing newline gets eaten)
    Object.class_eval @parser.compile "here's some raw text\n## hello world\n",
      :class_name => :CompilerSpecDelta
    Walrus::Grammar::CompilerSpecDelta.new.fill.should == "here's some raw text\n"

    # same but with no trailing newline
    Object.class_eval @parser.compile "here's some raw text\n## hello world",
      :class_name => :CompilerSpecGamma
    Walrus::Grammar::CompilerSpecGamma.new.fill.should == "here's some raw text\n"
  end
end
