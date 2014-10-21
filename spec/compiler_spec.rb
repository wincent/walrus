# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'spec_helper'

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
