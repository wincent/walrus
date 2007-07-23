# Copyright 2007 Wincent Colaiuta
# $Id: error_collector.rb 92 2007-02-26 17:01:41Z wincent $

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