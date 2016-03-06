require 'optparse'
require 'logger'

class OptionParser
 
  def arg name, desc
    @args = {} unless @args
    @args[name] = desc
  end
  
  def args
    return @args || {}
  end
  
end

module GitModule
  class SubCommandException < GitModuleException
  end
    
  class SubCommand  
    @@SUBCOMMANDS = nil

    def self.create name, args
      matches = SubCommand.subcommands.keys.grep(/^#{name}/)
      if matches.size == 1
        cmd = SubCommand.subcommands[matches[0]]
        return cmd.new args
      end
      return nil
    end
    
    def self.subcommands
      unless @@SUBCOMMANDS
        clazzes = ObjectSpace.each_object(Class).select { |clazz| clazz < self } 
        @@SUBCOMMANDS = clazzes.map! { |c| [ c.command, c ] }.sort.to_h
      end
      return @@SUBCOMMANDS
    end
        
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
    
    def usage      
      puts @opt_parser.help
      exit 1
    end
  end
end

# require subcommands
require_relative 'Add.rb'
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
