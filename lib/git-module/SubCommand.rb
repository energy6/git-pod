require 'optparse'
require 'git'

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
        
    def initialize args
      @repo = Git.open(Dir.pwd, :log => Logger.new(STDOUT))
      pp @repo.config
      @args = args
      @options = {}
      @opt_parser = OptionParser.new do |opts|
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          @options[:verbose] = v
        end
      end
    end
            
    def exec
      @opt_parser.parse!(@args)
    end
  end
end
