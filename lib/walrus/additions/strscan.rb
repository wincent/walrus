# Copyright 2007 Wincent Colaiuta
# $Id$

require 'strscan'

# Additional methods added to the StringScanner class for working with end-of-lines.
class StringScanner

  # Carriage return.
  CR="\r"

  # Linefeed.
  LF="\n"

  # Carriage return/linefeed.
  CRLF="\r\n"
  
  def scan_eol
    self.scan(/#{CRLF}|#{CR}|#{LF}/)
  end

  # A method for scanning up to but not past an end-of-line marker (the problem with "scan_until" is that it actually means "scan_up_to_and_past").
  def scan_up_to_eol
    self.scan(/[^#{CR}#{LF}]+/)
  end

end

