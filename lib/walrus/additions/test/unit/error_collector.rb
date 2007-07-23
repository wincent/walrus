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

require 'walrus'

module Test
  module Unit
    
    # See http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/138320
    # Usage:
    # 
    #   require 'test/unit'
    #   require 'walrus/additions/test/unit/error_collector'
    #   
    #   class TestClass < Test::Unit::TestCase
    #     
    #     include Test::Unit::ErrorCollector
    #     
    #     def test_method
    #       collecting_errors do
    #         assert false
    #         assert false
    #       end
    #     end
    #     
    #   end
    #   
    module ErrorCollector
      
      def collecting_errors
        # save state prior to yielding to block
        is_collecting = @is_collecting
        @is_collecting = true
        yield
      ensure
        # restore state on leaving block
        @is_collecting = is_collecting
      end
      
      def raise(*)
        super
      rescue Test::Unit::AssertionFailedError
        handle_error(:add_failure, $!)
      rescue StandardError, ScriptError
        handle_error(:add_error, $!)
      end
      
      def handle_error(method, error)
        backtrace = error.backtrace
        backtrace.shift # raise shouldn't appear in the backtrace
        if @is_collecting
          backtrace.slice!(5, 2) # remove collecting_errors and corresponding block
          send(method, error.message, backtrace)
        else
          Kernel.raise(error, error.message, backtrace)
        end
      end
      
    end
    
  end
end