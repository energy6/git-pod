require 'pp'
require 'git'

module GitPod
  # Pod specific exception
  class GitPodException < Exception
  end
  
  # Main class
  class GitPod

    # Runs the subcommand provided on command line
    # argv - Array with command line arguments, should contain the subcommand, options and arguments 
    def self.run(argv)
      begin
        name = argv.shift
        return exec(name, argv)
      rescue GitPodException => e        
        puts e.message
        return 1
      rescue Exception => e
        puts e.message if e.message && !e.message.empty?
        puts e.backtrace
        return 1
      end
    end

    # Execute the named subcommand with further options/arguments.
    # name - Name of the subcommand
    # args - Array with options and arguments
    def self.exec name, args
      unless name
        usage()
        return 1 
      else
        cmd = SubCommand.create(name, args)
        if cmd
          begin
            cmd.exec
            return 0
          rescue SystemExit => e
            return e.status
          end
        else
          usage()
          return 1
        end
      end
    end
    
    # Prints out the usage help to STDOUT
    # At this stage of usage all
    # available subcommands are listed.
    def self.usage
      puts "Usage: git pod <subcommand>"
      puts "Subcommands:"
      width = SubCommand.subcommands.keys.collect{ |k| k.size }.max
      SubCommand.subcommands.each do |cmd, clazz|
        puts "  %-#{width+5}{cmd} %{desc}" % { :cmd => cmd, :desc => clazz.description }
      end
      puts ""
    end

    # Combines two YAML configuration files given
    # by argv[1] and argv[2]. The content of the
    # two files is simply combined using Hash#merge
    def self.merge(argv)
      contentA = YAML.load(File.read(argv[1]))
      contentB = YAML.load(File.read(argv[2]))
      File.open(argv[1], 'w+') do |file|
        file.puts contentA.merge(contentB).to_yaml
      end
      return 0
    end
        
  end
end

require_relative 'git-pod/Git.rb'
require_relative 'git-pod/Metadata.rb'
require_relative 'git-pod/Pod.rb'
require_relative 'git-pod/SubCommand.rb'

