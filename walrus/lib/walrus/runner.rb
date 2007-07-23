# Copyright 2007 Wincent Colaiuta
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: runner.rb 185 2007-04-12 16:56:29Z wincent $

require 'walrus'
require 'fileutils'
require 'optparse'
require 'ostruct'
require 'pathname'
require 'rubygems'
require 'wopen3'

module Walrus
  
  class Runner
    
    class Error < Exception ; end

    class ArgumentError < Error ; end
    
    def initialize
      
      @options = OpenStruct.new
      @options.output_dir         = nil
      @options.input_extension    = 'tmpl'
      @options.output_extension   = 'html'
      @options.recurse            = false
      @options.backup             = true
      @options.force              = false
      @options.debug              = false
      @options.halt               = false
      @options.dry                = false
      @options.verbose            = false
      
      @command  = nil # "compile", "fill" (saves to disk), "run" (prints to standard out)
      @inputs   = []  # list of input files and/or directories
      parser    = OptionParser.new do |o|
        
        o.banner  = "Usage: #{o.program_name} command input-file(s)-or-directory/ies [options]"
        o.separator ''
        o.separator '   _____________'
        o.separator '  /             \\'
        o.separator " /     o   o     \\  #{o.program_name}"
        o.separator ' |       b       |  Command-line front-end for the Walrus templating system'
        o.separator '  \\   ~-----~   /   Copyright 2007 Wincent Colaiuta'
        o.separator '   \\ / /   \\ \\ /'
        o.separator '    / /-----\\ \\'
        o.separator '   |_/       \\_|'
        o.separator ''
        o.separator 'Commands: compile -- compile templates to Ruby code'
        o.separator '          fill    -- runs compiled templates, writing output to disk'
        o.separator '          run     -- runs compiled templates, printing output to standard output'
        o.separator ''
        
        o.on('-o', '--output-dir DIR', 'Output directory (when filling)', 'defaults to same directory as input file') do |opt|
          @options.output_dir = Pathname.new(opt)
        end
        
        o.on('-i', '--input-extension EXT', 'Extension for input file(s)', 'default: tmpl') do |opt|
          @options.input_extension = opt
        end
        
        o.on('-e', '--output-extension EXT', 'Extension for output file(s) (when filling)', 'default: html') do |opt|
          @options.output_extension = opt
        end
        
        o.on('-R', 'Search subdirectories recursively for input files', 'default: on') do |opt|
          @options.recurse = opts
        end
        
        o.on('-b', '--[no-]backup', 'Make backups before overwriting', 'default: on') do |opt|
          @options.backup = opt
        end
        
        o.on('-f', '--force', 'Force a recompile (when filling)', 'default: off (files only recompiled if source newer than output)') do |opt|
          @options.force = opt
        end
        
        o.on('--halt', 'Halts on encountering an error (even a non-fatal error)', 'default: off') do |opt|
          @options.halt = opt
        end
        
        o.on('-t', '--test', 'Performs a "dry" (test) run', 'default: off') do |opt|
          @options.dry = opt
        end
        
        o.on('-d', '--debug', 'Print debugging information to standard error', 'default: off') do |opt|
          @options.debug = opt
        end
        
        o.on('-v', '--verbose', 'Run verbosely', 'default: off') do |opt|
          @options.verbose = opt
        end
        
        o.separator ''
        
        o.on_tail('-h', '--help', 'Show this message') do
          $stderr.puts o
          exit
        end
        
        o.on_tail('--version', 'Show version') do
          $stderr.puts 'Walrus ' + Walrus::VERSION
          exit
        end
        
      end
      
      begin
        parser.parse!
      rescue OptionParser::InvalidOption => e
        raise ArgumentError.new(e)
      end
      
      parser.order! do |item|
        if @command.nil? :  @command = item               # get command first ("compile", "fill" or "run")
        else                @inputs << Pathname.new(item) # all others (and there must be at least one) are file or directory names
        end
      end
      
      raise ArgumentError.new('no command specified') if @command.nil?
      raise ArgumentError.new('no inputs specified') unless @inputs.length > 0
    end
    
    def run
      log "Beginning processing: #{Time.new.to_s}."
      
      # TODO: flush memoizing cache after each file
      
      expand(@inputs).each do |input|
        case @command
        when 'compile'
          log "Compiling '#{input}'."
          compile(input)
        when 'fill'
          log "Filling '#{input}'."
          compile_if_needed(input)
          begin
            write_string_to_path(get_output(input), filled_output_path_for_input(input))
          rescue Exception => e
            handle_error(e)
          end
        when 'run'
          log "Running '#{input}'."
          compile_if_needed(input)
          begin
            printf('%s', get_output(input))
            $stdout.flush
          rescue Exception => e
            handle_error(e)
          end
        else
          raise ArgumentError.new("unrecognized command '#{@command}'")
        end
      end
      log "Processing complete: #{Time.new.to_s}."
    end
    
    # Expects an array of Pathname objects.
    # Directory inputs are themselves recursively expanded if the "recurse" option is set to true; otherwise only their top-level entries are expanded.
    # Returns an expanded array of Pathname objects.
    def expand(inputs)
      expanded = []
      inputs.each do |input|
        if input.directory?
          input.entries.each do |entry|
            if entry.directory?
              if @options.recurse
                expanded.concat expand(entry.entries)
              end
            else # not a directory
              expanded << entry
            end
          end
        else # not a directory
          expanded << input
        end
      end
      expanded
    end
    
    def compile_if_needed(input)
      compile(input, false)
    end
    
    def compiled_path_older_than_source_path(compiled_path, source_path)
      begin
        compiled  = File.mtime(compiled_path)
        source    = File.mtime(source_path)
      rescue SystemCallError # perhaps one of them doesn't exist
        return true
      end
      compiled < source
    end
    
    def compile(input, force = true)
      template_source_path  = template_source_path_for_input(input)
      compiled_path         = compiled_source_path_for_input(input)
      if force or @options.force or not compiled_path.exist? or compiled_path_older_than_source_path(compiled_path, template_source_path)
        begin
          template = Template.new(template_source_path)
        rescue Exception => e
          handle_error("failed to read input template '#{template_source_path}' (#{e.to_s})")
          return
        end
        
        begin
          compiled = template.compile
        rescue Grammar::ParseError => e
          handle_error("failed to compile input template '#{template_source_path}' (#{e.to_s})")
          return
        end
        
        write_string_to_path(compiled, compiled_path, true)
        
      end
      
    end
    
    def get_output(input)
      if @options.dry
        "(no output: dry run)\n"
      else
        # use Wopen3 (backticks choke if there is a space in the path, open3 throws away the exit status)
        output = ''
        Wopen3.popen3([compiled_source_path_for_input(input).realpath, '']) do |stdin, stdout, stderr|
          threads = []
          threads << Thread.new(stdout) do |out|
            out.each { |line| output << line }
          end
          threads << Thread.new(stderr) do |err|
            err.each { |line| STDERR.puts line }
          end
          threads.each { |thread| thread.join }      
        end
        status = $?.exitstatus
        raise SystemCallError.new("non-zero exit status (#{status})") if status != 0
        output
      end
    end
    
    def write_string_to_path(string, path, executable = false)
      
      if @options.dry
        log "Would write '#{path}' (dry run)."
      else
        
        unless path.dirname.exist?
          begin
            log "Creating directory '#{path.dirname}'."
            FileUtils.mkdir_p path.dirname
          rescue SystemCallError => e
            handle_error(e)
            return
          end
        end
        
        log "Writing '#{path}'."
        begin
          File.open(path, "a+") do |f|
            if not File.zero? path and @options.backup
              log "Making backup of existing file at '#{path}'."
              dir, base = path.split
              FileUtils.cp path, dir + "#{base.to_s}.bak"
            end
            f.flock File::LOCK_EX
            f.truncate 0
            f.write string
            f.chmod 0744 if executable
          end
        rescue SystemCallError => e
          handle_error(e)
        end
      end
    end
    
    def adjusted_output_path(path)
      if @options.output_dir
        if path.absolute?
          path = @options.output_dir + path.to_s.sub(/\A\//, '')
        else
          path = @options.output_dir + path
        end
      else
        path
      end
    end
    
    # If "input" already has the right extension it is returned unchanged.
    # If the "input extension" is zero-length then "input" is returned unchanged.
    # Otherwise the "input extension" is added to "input" and returned.
    def template_source_path_for_input(input)
      return input if input.extname == ".#{@options.input_extension}" # input already has the right extension
      return input if @options.input_extension.length == 0            # zero-length extension, nothing to add
      dir, base = input.split      
      dir + "#{base.to_s}.#{@options.input_extension}"                # otherwise, add extension and return
    end
    
    def compiled_source_path_for_input(input)
      
      # remove input extension if present
      if input.extname == ".#{@options.input_extension}" and @options.input_extension.length > 0
        dir, base = input.split
        input = dir + base.basename(base.extname)
      end
      
      # add rb as an extension
      dir, base = input.split
      dir + "#{base.to_s}.rb"
    end
    
    def filled_output_path_for_input(input)
      
      # remove input extension if present
      if input.extname == ".#{@options.input_extension}" and @options.input_extension.length > 0
        dir, base = input.split
        input = dir + base.basename(base.extname)
      end
      
      # add output extension if appropriate
      if @options.output_extension.length > 0
        dir, base = input.split
        adjusted_output_path(dir + "#{base.to_s}.#{@options.output_extension}")
      else
        adjusted_output_path(input)
      end
      
    end
    
  private
    
    # Writes "message" to standard error if user supplied the "--verbose" switch.
    def log(message)
      if @options.verbose
        $stderr.puts message
      end
    end
    
    # If the user supplied the "--halt" switch raises an Runner::Error exception based on "message". Otherwise merely prints "message" to the standard error.
    def handle_error(message)
      if @options.halt
        raise Error.new(message)
      else
        $stderr.puts message
      end
    end
    
    
  end # class Runner
  
end # module Walrus

