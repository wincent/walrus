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

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Walrus
  
  class ByCopyAccessDemo
    attr_bycopy           :foo
    attr_bycopy           :bar, false
    attr_bycopy           :baz, true
    attr_writer_bycopy    :beta
    attr_accessor_bycopy  :gamma
    attr_writer_bycopy    :beta2, :beta3
    attr_accessor_bycopy  :gamma2, :gamma3
  end
  
  describe 'using "by copy" accessors' do
    
    before(:each) do
      @instance = ByCopyAccessDemo.new
    end
    
    it 'those accessors should be "private"' do
      lambda { ByCopyAccessDemo.attr_bycopy :hello }.should raise_error(NoMethodError)
      lambda { ByCopyAccessDemo.attr_writer_bycopy :hello }.should raise_error(NoMethodError)
      lambda { ByCopyAccessDemo.attr_accessor_bycopy :hello }.should raise_error(NoMethodError)
    end
    
    it 'should accept "normal" objects like String, making copies of them' do
      
      # original values
      foo     = "hello"
      bar     = "world"
      baz     = "..."
      beta    = "abc"
      gamma   = "def"
      beta2   = "ghi"
      beta3   = "jkl"
      gamma2  = "mno"
      gamma3  = "pqr"
      
      # assignments
      lambda { @instance.foo = foo }.should raise_error(NoMethodError) # no writer defined
      lambda { @instance.bar = bar }.should raise_error(NoMethodError) # no writer defined
      @instance.baz     = baz
      @instance.beta    = beta
      @instance.gamma   = gamma
      @instance.beta2   = beta2
      @instance.beta3   = beta3
      @instance.gamma2  = gamma2
      @instance.gamma3  = gamma3
      
      # check equality
      @instance.baz.should == baz
      @instance.instance_eval { @beta }.should  == beta   # no reader defined
      @instance.gamma.should == gamma
      @instance.instance_eval { @beta2 }.should == beta2  # no reader defined
      @instance.instance_eval { @beta3 }.should == beta3  # no reader defined
      @instance.gamma2.should == gamma2
      @instance.gamma3.should == gamma3
      
      # check that copies were made
      @instance.baz.object_id.should_not == baz.object_id
      @instance.instance_eval { @beta }.object_id.should_not == beta.object_id    # no reader defined
      @instance.gamma.object_id.should_not == gamma.object_id
      @instance.instance_eval { @beta2 }.object_id.should_not == beta2.object_id  # no reader defined
      @instance.instance_eval { @beta3 }.object_id.should_not == beta3.object_id  # no reader defined
      @instance.gamma2.object_id.should_not == gamma2.object_id
      @instance.gamma3.object_id.should_not == gamma3.object_id
      
    end
    
    it 'should accept non-copyable objects like instances of Nil, Symbol and Fixnum' do
      
      # original values
      foo     = nil
      bar     = 1
      baz     = 2
      beta    = 3
      gamma   = 4
      beta2   = nil
      beta3   = 5
      gamma2  = nil
      gamma3  = :symbol
      
      # assignments
      lambda { @instance.foo = foo }.should raise_error(NoMethodError) # no writer defined
      lambda { @instance.bar = bar }.should raise_error(NoMethodError) # no writer defined
      @instance.baz     = baz
      @instance.beta    = beta
      @instance.gamma   = gamma
      @instance.beta2   = beta2
      @instance.beta3   = beta3
      @instance.gamma2  = gamma2
      @instance.gamma3  = gamma3
      
      # check equality
      @instance.baz.should == baz
      @instance.instance_eval { @beta }.should == beta    # no reader defined
      @instance.gamma.should == gamma
      @instance.instance_eval { @beta2 }.should == beta2  # no reader defined
      @instance.instance_eval { @beta3 }.should == beta3  # no reader defined
      @instance.gamma2.should == gamma2
      @instance.gamma3.should == gamma3
      
      # check that copies were not made
      @instance.baz.object_id.should == baz.object_id
      @instance.instance_eval { @beta }.object_id.should == beta.object_id    # no reader defined
      @instance.gamma.object_id.should == gamma.object_id
      @instance.instance_eval { @beta2 }.object_id.should == beta2.object_id  # no reader defined
      @instance.instance_eval { @beta3 }.object_id.should == beta3.object_id  # no reader defined
      @instance.gamma2.object_id.should == gamma2.object_id
      @instance.gamma3.object_id.should == gamma3.object_id
      
    end
    
  end
  
end
