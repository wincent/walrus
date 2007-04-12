# Copyright 2007 Wincent Colaiuta
# $Id$

# Wopen3 is a replacement for Open3.
#
# Unlike Open3, Wopen3 does not throw away the exit code of the executed (grandchild) process.
# Only a child process is spawned and the exit status is returned in $? as normal.
#
# Usage example:
#
#   result, errors = '', ''
#   Wopen3.popen3('svn', 'log') do |stdin, stdout, stderr|
#     threads = []
#     threads << Thread.new(stdout) do |out|
#       out.each { |line| result << line }
#     end
#     threads << Thread.new(stderr) do |err|
#       err.each { |line| errors << line }
#     end
#     threads.each { |thread| thread.join }      
#   end
#   status = $?.exitstatus
#   raise "Non-zero exit status #{status}" if status != 0
#
#
module Wopen3
  
  class Opener
    
    READ  = 0
    WRITE = 1
    
    def initialize(*cmd)
      
      write_pipe  = IO::pipe
      read_pipe   = IO::pipe
      error_pipe  = IO::pipe
      
      pid = fork do
        
        # in child
        write_pipe[WRITE].close
        STDIN.reopen(write_pipe[READ])    # file descriptor duplicated here
        write_pipe[READ].close            # must close in order for parent to see EOF
        
        read_pipe[READ].close
        STDOUT.reopen(read_pipe[WRITE])
        read_pipe[WRITE].close
        
        error_pipe[READ].close
        STDERR.reopen(error_pipe[WRITE])
        error_pipe[WRITE].close
        
        exec(*cmd)  # will raise SystemCallError if command can't be executed (eg Errno::NOENT)
        exit!       # should never get here
        
      end
      
      # in parent
      write_pipe[READ].close
      read_pipe[WRITE].close
      error_pipe[WRITE].close
      
      pipes = [write_pipe[WRITE], read_pipe[READ], error_pipe[READ]]
      write_pipe[WRITE].sync = true
      
      if defined? yield
        begin
          result = yield(*pipes)
          Process.waitpid(pid) # global $? gets set here
          return result
        ensure
          pipes.each { |pipe| pipe.close unless pipe.closed? }
        end
      end
      
      # can't wait immediately (will hang); wait once garbage collection destroys/finalizes this instance
      ObjectSpace.define_finalizer(self, proc { Process.waitpid(pid) })
      pipes
      
    end
    
  end
  
  def self.popen3(*cmd, &block)
    Opener.new(*cmd, &block)
  end
  
end # module Wopen3
