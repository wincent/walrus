# Copyright 2007 Wincent Colaiuta
# $Id$

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

context 'converting from class names to require names' do
  
  specify 'should work with single letters' do
    'A'.to_require_name.should == 'a'
  end
  
  specify 'should work with runs of capitals' do
    'EOLToken'.to_require_name.should == 'eol_token'
  end
  
  specify 'should work with consecutive underscores' do
    'EOL__Token'.to_require_name.should == 'eol__token'
    'EOL__token'.to_require_name.should == 'eol__token'
    'Eol__Token'.to_require_name.should == 'eol__token'
    'Eol__token'.to_require_name.should == 'eol__token'
  end
  
  specify 'should work with trailing underscores' do
    'EOL__'.to_require_name.should == 'eol__'
    'Eol__'.to_require_name.should == 'eol__'
  end
  
  specify 'should work with standard classnames' do
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

context 'converting from require names to class names' do
  
  specify 'should work with standard case' do
    'foo_bar'.to_class_name.should == 'FooBar'
  end
  
  specify 'should work with single-letter' do
    'f'.to_class_name.should == 'F'
  end
  
  specify 'should work with double-underscores' do
    'foo__bar'.to_class_name.should == 'FooBar'
  end
  
  specify 'should work with terminating double-underscores' do
    'foo__'.to_class_name.should == 'Foo'
  end
  
  specify "shouldn't preserve uppercase acronym information lost on the conversion from class name to require name" do
    'eol_token'.to_class_name.should == 'EolToken'
  end
  
end

context 'converting to source strings' do
  
  specify 'standard strings should be unchanged' do
    ''.to_source_string.should == ''
    'hello world'.to_source_string.should == 'hello world'
    "hello\nworld".to_source_string.should == "hello\nworld"
  end
  
  specify 'single quotes should be escaped' do
    "'foo'".to_source_string.should == "\\'foo\\'"
  end
  
  specify 'backslashes should be escaped' do
    'hello\\nworld'.to_source_string.should == "hello\\\\nworld"
  end
  
  specify 'should work with Unicode characters' do
    '€ información…'.to_source_string.should == '€ información…'
  end
  
  specify 'should be able to round trip' do
    eval("'" + ''.to_source_string + "'").should == ''
    eval("'" + 'hello world'.to_source_string + "'").should == 'hello world'
    eval("'" + "hello\nworld".to_source_string + "'").should == "hello\nworld"
    eval("'" + "'foo'".to_source_string + "'").should == '\'foo\''
    eval("'" + 'hello\\nworld'.to_source_string + "'").should == 'hello\\nworld'
    eval("'" + '€ información…'.to_source_string + "'").should == '€ información…'
  end
  
end
