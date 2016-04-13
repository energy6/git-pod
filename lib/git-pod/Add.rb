require 'rake'

module GitModule
  # Implementation of the subcommand "git module add"
  # This subcommand transferes files from the active branch to the module
  # and adds them to the index for a later commit, see GitModule::Commit.
  class Add < SubCommand  

    # Command
    def self.command
      "add"
    end
    
    # Description
    def self.description
      "Add files to a module's index"
    end
    
    # Create a subcommand instance with given args.   
    def initialize(args)
      super(args) do |opts|
        opts.arg("<file> [<file> ...]", "Files to be added to the module's index")

        opts.on("-m", "--module NAME", "Module to add the file to") do |v|
          @options[:module] = v
        end

        opts.on("-b", "--branch [NAME]", "Modules branch to add file to") do |v|
          @options[:branch] = v
        end
      end
    end

    # Execute the command
    def exec
      super do        
        raise SubCommandException, "Module must be given" unless @options[:module]
        raise SubCommandException, "No files given" if @args.size < 1

        mod = Module.new(@options[:module])

        branch = @options[:branch] || "master"        
        files = @args.collect{ |a| Rake::FileList[a] }.flatten!

        mod.addFiles(branch, files)
      end
    end
        
  end
end

