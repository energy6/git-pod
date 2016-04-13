require 'optparse'
require 'logger'

# Monkey patch for the OptionParser
class OptionParser
 
  # Define a new argument with name and description.
  def arg name, desc
    @args = {} unless @args
    @args[name] = desc
  end
  
  # Returns the Hash with all previously defined arguments
  # Keys are argument names, values are the description 
  def args
    return @args || {}
  end
  
end

module GitModule
  # Exception for SubEommand
  class SubCommandException < GitModuleException
  end
    
  # git module <subcommand>
  # Each subcommand provides a single action.
  # This base class defines some common
  # command line options valid for all subcommands.
  class SubCommand  
    @@SUBCOMMANDS = nil

    # Create a subcommand instance for the
    # named subcommand and an array of arguments.
    # All subclasses of SubCommand are searched
    # for a class which implements a command
    # matching the given name (used like a regex).
    # The given command name must not be an exact
    # but a single match. 
    def self.create name, args
      matches = SubCommand.subcommands.keys.grep(/^#{name}/)
      if matches.size == 1
        cmd = SubCommand.subcommands[matches[0]]
        return cmd.new args
      end
      return nil
    end
    
    # Helper to collect all subclasses of SubCommand
    # and cache them in a global command map.
    def self.subcommands
      unless @@SUBCOMMANDS
        clazzes = ObjectSpace.each_object(Class).select { |clazz| clazz < self } 
        @@SUBCOMMANDS = clazzes.map! { |c| [ c.command, c ] }.sort.to_h
      end
      return @@SUBCOMMANDS
    end
        
    # Create a new Subcommand instance with the given arguments. The arguments
    # are stored internally to be evaluated on command execution.
    #
    # An optional block can be provided to hook into the option parser
    # configuration phase. The block is called after the default options are
    # configured. The option parser instance is given as an argument to the
    # block.
    def initialize args, &block
      @args = args
      @opt_parser = OptionParser.new do |opts|
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          @options[:verbose] = v
        end
        
        yield opts if block_given?

        opts.banner = "Usage: git module "
        opts.banner << self.class.command
        opts.banner << " [options]"
        opts.args.each { |a,d| opts.banner << " #{a}" }
        opts.banner << "\n" << self.class.description << "\n"
        opts.args.each do |arg, desc|
          name = arg[/[<\[]?(\w+)[>\]]?/, 1]
          optional = arg.start_with?("[")
          
          opts.banner << opts.summary_indent << "%-#{opts.summary_width}s #{desc}\n" % name
        end
      end
      @options = {}
    end
            
    # Execute the subcommand with the stored arguments.
    # This method should be overridden by any subclass and called with a block
    # provided. Within the block the subcommands actions should be performed.
    # In case of an subcommand error, the subcommand can raise a
    # SubCommandException. This leads to printing out the usage information
    # automatically.
    def exec
      @opt_parser.parse!(@args)
      begin
        yield if block_given?
      rescue GitModuleException => e
        STDERR.puts e.message
        usage()        
      end
      return 0
    end
    
    # Print out the usage information, see OptionParser#help.
    def usage      
      puts @opt_parser.help
      exit 1
    end
  end
end

# require subcommands
require_relative 'Add.rb'
require_relative 'Checkout.rb'
require_relative 'Create.rb'
require_relative 'Commit.rb'
require_relative 'List.rb'
require_relative 'Migrate.rb'
require_relative 'Remove.rb'
require_relative 'Select.rb'
require_relative 'Setup.rb'
require_relative 'Status.rb'
require_relative 'Upgrade.rb'
require_relative 'Update.rb'
