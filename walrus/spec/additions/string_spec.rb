# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: string_spec.rb 166 2007-04-09 15:04:40Z wincent $

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'converting from class names to require names' do
  
  it 'should work with single letters' do
    'A'.to_require_name.should == 'a'
  end
  
  it 'should work with runs of capitals' do
    'EOLToken'.to_require_name.should == 'eol_token'
  end
  
  it 'should work with consecutive underscores' do
    'EOL__Token'.to_require_name.should == 'eol__token'
    'EOL__token'.to_require_name.should == 'eol__token'
    'Eol__Token'.to_require_name.should == 'eol__token'
    'Eol__token'.to_require_name.should == 'eol__token'
  end
  
  it 'should work with trailing underscores' do
    'EOL__'.to_require_name.should == 'eol__'
    'Eol__'.to_require_name.should == 'eol__'
  end
  
  it 'should work with standard classnames' do
    'Foo'.to_require_name.should == 'foo'
    'MyURLHandler'.to_require_name.should == 'my_url_handler'
    'Signals37'.to_require_name.should == 'signals_37'
    'MyClass'.to_require_name.should == 'my_class'
    'Foo_bar'.to_require_name.should == 'foo_bar'
    'C99case'.to_require_name.should == 'c_99_case'
    'EOL99doFun'.to_require_name.should == 'eol_99_do_fun'
    'Foo_Bar'.to_require_name.should == 'foo_bar'
  end
  
end

describe 'converting from require names to class names' do
  
  it 'should work with standard case' do
    'foo_bar'.to_class_name.should == 'FooBar'
  end
  
  it 'should work with single-letter' do
    'f'.to_class_name.should == 'F'
  end
  
  it 'should work with double-underscores' do
    'foo__bar'.to_class_name.should == 'FooBar'
  end
  
  it 'should work with terminating double-underscores' do
    'foo__'.to_class_name.should == 'Foo'
  end
  
  it "shouldn't preserve uppercase acronym information lost on the conversion from class name to require name" do
    'eol_token'.to_class_name.should == 'EolToken'
  end
  
end

describe 'converting to source strings' do
  
  it 'standard strings should be unchanged' do
    ''.to_source_string.should == ''
    'hello world'.to_source_string.should == 'hello world'
    "hello\nworld".to_source_string.should == "hello\nworld"
  end
  
  it 'single quotes should be escaped' do
    "'foo'".to_source_string.should == "\\'foo\\'"
  end
  
  it 'backslashes should be escaped' do
    'hello\\nworld'.to_source_string.should == "hello\\\\nworld"
  end
  
  it 'should work with Unicode characters' do
    '€ información…'.to_source_string.should == '€ información…'
  end
  
  it 'should be able to round trip' do
    eval("'" + ''.to_source_string + "'").should == ''
    eval("'" + 'hello world'.to_source_string + "'").should == 'hello world'
    eval("'" + "hello\nworld".to_source_string + "'").should == "hello\nworld"
    eval("'" + "'foo'".to_source_string + "'").should == '\'foo\''
    eval("'" + 'hello\\nworld'.to_source_string + "'").should == 'hello\\nworld'
    eval("'" + '€ información…'.to_source_string + "'").should == '€ información…'
  end
  
end
