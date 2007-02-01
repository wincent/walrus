#!/usr/bin/env ruby
# Copyright 2007 Wincent Colaiuta
# $Id$

require '../test_helper' if not defined?(Walrus::TestHelper)
require 'walrus/additions/strscan'

# Tests for StringScanner additions.
class StringScannerTest < Test::Unit::TestCase
  
  def test_scanner_with_newline
    
    # test scan_up_to_eol
    scanner = StringScanner.new("Test\nText after newline")
    assert_equal "Test", scanner.scan_up_to_eol
    assert_equal 4, scanner.pos
    
    # test scan_eol
    assert_equal "\n", scanner.scan_eol
    assert_equal "Text after newline", scanner.scan_up_to_eol
    assert scanner.eos?
    assert_nil scanner.scan_up_to_eol
    
  end
  
  def test_scanner_with_carriage_return
  
    # same tests should work with carriage returns
    scanner = StringScanner.new("Test\rText after carriage return")
    assert_equal "Test", scanner.scan_up_to_eol
    assert_equal 4, scanner.pos
    assert_equal "\r", scanner.scan_eol
    assert_equal "Text after carriage return", scanner.scan_up_to_eol
    assert scanner.eos?
    assert_nil scanner.scan_up_to_eol
  
  end
  
  def test_scanner_with_carriage_return_and_linefeed  
    
    # same tests should work with carriage return/linefeed
    scanner = StringScanner.new("Test\r\nText after carriage return/linefeed")
    assert_equal "Test", scanner.scan_up_to_eol
    assert_equal 4, scanner.pos
    assert_equal "\r\n", scanner.scan_eol
    assert_equal "Text after carriage return/linefeed", scanner.scan_up_to_eol
    assert scanner.eos?
    assert_nil scanner.scan_up_to_eol
    
  end
  
  def test_scanner_with_many_lined_string
    
    scanner = StringScanner.new("Line1\nLine2\rLine3\r\nLine4\n\rLine5")
    assert_equal 0, scanner.pos
    assert_nil scanner.scan_eol
    assert_equal "Line1", scanner.scan_up_to_eol
    assert_equal "\n", scanner.scan_eol
    assert_equal "Line2", scanner.scan_up_to_eol
    assert_equal "\r", scanner.scan_eol
    assert_equal "Line3", scanner.scan_up_to_eol
    assert_equal "\r\n", scanner.scan_eol
    assert_equal "Line4", scanner.scan_up_to_eol
    assert_equal "\n", scanner.scan_eol # note only the LF scanned
    assert_equal "\r", scanner.scan_eol # then the CR separately (LFCR isn't valid, CRLF is)
    assert_equal "Line5", scanner.scan_up_to_eol
    assert_nil scanner.scan_eol
    assert scanner.eos?
    
  end
  
end
