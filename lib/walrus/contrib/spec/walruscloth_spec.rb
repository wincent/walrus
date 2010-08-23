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
