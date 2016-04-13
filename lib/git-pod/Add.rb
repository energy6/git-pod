require 'rake'

module GitPod
  # Implementation of the subcommand "git pod add"
  # This subcommand transferes files from the active branch to the pod
  # and adds them to the index for a later commit, see GitPod::Commit.
  class Add < SubCommand  

    # Command
    def self.command
      "add"
    end
    
    # Description
    def self.description
      "Add files to a pod's index"
    end
    
    # Create a subcommand instance with given args.   
    def initialize(args)
      super(args) do |opts|
        opts.arg("<file> [<file> ...]", "Files to be added to the pod's index")

        opts.on("-p", "--pod NAME", "Pod to add the file to") do |v|
          @options[:pod] = v
        end

        opts.on("-b", "--branch [NAME]", "Pods branch to add file to") do |v|
          @options[:branch] = v
        end
      end
    end

    # Execute the command
    def exec
      super do        
        raise SubCommandException, "Pod must be given" unless @options[:pod]
        raise SubCommandException, "No files given" if @args.size < 1

        mod = Pod.new(@options[:pod])

        branch = @options[:branch] || "master"        
        files = @args.collect{ |a| Rake::FileList[a] }.flatten!

        mod.addFiles(branch, files)
      end
    end
        
  end
end

