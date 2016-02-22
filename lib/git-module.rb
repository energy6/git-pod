require 'pp'

module GitModule
  class GitModuleException < Exception
  end
  
  class GitModule
    def self.run(argv)
      begin
        name = argv.shift
        return exec(name, argv)
      rescue GitModuleException => e        
        puts e.message
        return 1
      rescue Exception => e
        puts e.message if e.message && !e.message.empty?
        puts e.backtrace
        return 1
      end
    end

    def self.exec name, args
      unless name
        usage()
        return 1 
      else
        cmd = SubCommand.create(name, args)
        if cmd
          return cmd.exec
        else
          usage()
          return 1
        end
      end
    end
    
    def self.usage
      puts "Usage: git module <subcommand>"
      puts "Subcommands:"
      SubCommand.subcommands.each do |cmd, clazz|
        puts "  %{cmd} - %{desc}" % { :cmd => cmd, :desc => clazz.description }
      end
      puts ""
    end
        
  end
end

# require subcommands
require_relative 'git-module/Create.rb'
require_relative 'git-module/Remove.rb'

