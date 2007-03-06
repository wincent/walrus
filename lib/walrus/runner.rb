# Copyright 2007 Wincent Colaiuta
# $Id$

require 'walrus'
require 'fileutils'
require 'optparse'
require 'ostruct'
require 'pathname'

module Walrus
  
  class Runner
    
    class Error < Exception ; end

    class ArgumentError < Error ; end
    
    def initialize
      
      @options = OpenStruct.new
      @options.input_extension    = 'tmpl'
      @options.output_extension   = 'html'
      @options.recurse            = false
      @options.backup             = true
      @options.debug              = false
      @options.verbose            = false
      
      @command  = nil # "compile", "fill" (saves to disk), "run" (prints to standard out)
      @inputs   = []  # list of input files and/or directories
      parser    = OptionParser.new do |o|
        
        o.banner  = "Usage: #{o.program_name} command input-file(s)-or-directory/ies [options]"
        o.separator ''
        #   _____________
        #  /             \
        # /     o   o     \
        # |       b       |
        #  \   ~-----~   /
        #   \ / /   \ \ /
        #    / /-----\ \
        #   |_/       \_|        
        o.separator "#{o.program_name} - command-line front-end for the Walrus templating system"
        o.separator 'Copyright 2007 Wincent Colaiuta'
        o.separator ''
        o.separator 'Commands: compile -- compile templates to Ruby code'
        o.separator '          fill    -- runs compiled templates, writing output to disk'
        o.separator '          run     -- runs compiled templates, printing output to standard output'
        o.separator ''
        
        o.on('-o', '--output-dir', 'Output directory', 'defaults to same directory as input file') do |opt|
          @options.output_dir = opt
        end
        
        o.on('-i', '--input-extension', 'Extension for input file(s)', 'default: tmpl') do |opt|
          @options.input_extension = opt
        end
        
        o.on('-e', '--output-extension', 'Extension for output file(s) (when filling)', 'default: html') do |opt|
          @options.output_extension = opt
        end
        
        o.on('-R', 'Search subdirectories recursively for input files', 'default: on') do |opt|
          @options.recurse = opts
        end
        
        o.on('-b', '--[no-]backup', 'Make backups before overwriting', 'default: backup') do |opt|
          @options.backup = opt
        end
        
        o.on_tail('-d', '--debug', 'Print debugging information to standard error', 'default: off') do |opt|
          @options.debug = opt
        end
        
        o.on_tail('-h', '--help', 'Show this message') do
          $stderr.puts o
          exit
        end
        
        o.on_tail('-v', '--verbose', 'Run verbosely', 'default: off') do |opt|
          @options.verbose = opt
        end
        
        o.on_tail('--version', 'Show version') do
          $stderr.puts 'Walrus ' + Walrus::VERSION
          exit
        end
        
      end
      
      parser.parse!
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
      expand(@inputs).each do |input|
        case @command
        when 'compile'
          log "Compiling #{input}."
          compile(input)
        when 'fill'
          log "Filling #{input}."
          compile_if_needed(input)
          output = `#{compiled_source_path_for_input(input).realpath}`
          write_string_to_path(output, filled_output_path_for_input(input))
        when 'run'
          log "Running #{input}."
          compile_if_needed(input)
          printf('%s',`#{compiled_source_path_for_input(input).realpath}`)
          $stdout.flush
        else
          raise ArgumentError.new("unrecognized command '#{@command}'")
        end
      end
      log "Processing complete: #{Time.new.to_s}."
    end
    
    # Expects an array of Pathname objects.
    # Any file inputs are passed through the "sanitize_input" method.
    # If an input is a directory then its contents are also checked: file inputs are passed through the "sanitize_input" method, and directory inputs are themselves recursively expanded if the "recurse" option is set to true.
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
    
    def compile(input, force = true)
      template_source_path  = template_source_path_for_input(input)
      compiled_path         = compiled_source_path_for_input(input)
      
      if force or not compiled_path.exist?
        
        begin
          template = Template.new(template_source_path)
        rescue Exception => e
          raise Error.new("failed to read input template '#{template_source_path}' (#{e.to_s})")
        end
        
        begin
          compiled = template.compile
        rescue Grammar::ParseError => e
          raise Error.new("failed to compile input template '#{template_source_path}' (#{e.to_s})")
        end
        
        write_string_to_path(compiled, compiled_path)
        
      end
      
    end
    
    def write_string_to_path(string, path)
      log "Writing #{path}."      
      File.open(path, "a+") do |f|
        if not File.zero? path and @options.backup
          log "Making backup of existing file at #{path}."
          dir, base = path.split
          FileUtils.cp path, dir + "#{base.to_s}.bak"
        end
        f.flock File::LOCK_EX
        f.truncate 0
        f.write string
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
        dir + "#{base.to_s}.#{@options.output_extension}"
      else
        input
      end
      
    end
    
  private
    
    # Writes to standard error if @options.verbose is true.
    def log(message)
      if @options.verbose
        $stderr.puts message
      end
    end
    
  end # class Runner
  
end # module Walrus


