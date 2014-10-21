# Copyright 2007-2014 Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'rubygems'
require 'spec'
require File.expand_path('../walruscloth', File.dirname(__FILE__))

describe 'using WalrusCloth' do
  it 'should be able to create an unordered list' do
    # => "<ul>\n\t<li>hello</li>\n\t</ul>"
    WalrusCloth.new('* hello').to_html.should == RedCloth.new('* hello').to_html
  end

  it 'should be able to create an ordered list' do
    # => "<ol>\n\t<li>hello</li>\n\t</ol>"
    WalrusCloth.new('` hello').to_html.should == RedCloth.new('# hello').to_html
  end

  it 'should be able to nest lists' do
    # => "<ol>\n\t<li>hello\n\t<ul>\n\t<li>world</li>\n\t</ol></li>\n\t</ul>"
    WalrusCloth.new("` hello\n`* world").to_html.should == RedCloth.new("# hello\n#* world").to_html
  end
end
