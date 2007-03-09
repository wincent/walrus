#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require 'rubygems'
require 'spec'
require File.join(File.dirname(__FILE__), '..', 'walruscloth')

context 'using WalrusCloth' do
  
  specify 'should be able to create an unordered list' do
    # => "<ul>\n\t<li>hello</li>\n\t</ul>"
    WalrusCloth.new('* hello').to_html.should == RedCloth.new('* hello').to_html
  end
  
  specify 'should be able to create an ordered list' do
    # => "<ol>\n\t<li>hello</li>\n\t</ol>"
    WalrusCloth.new('` hello').to_html.should == RedCloth.new('# hello').to_html
  end
  
  specify 'should be able to nest lists' do
    # => "<ol>\n\t<li>hello\n\t<ul>\n\t<li>world</li>\n\t</ol></li>\n\t</ul>"
    WalrusCloth.new("` hello\n`* world").to_html.should == RedCloth.new("# hello\n#* world").to_html
  end
  
end

