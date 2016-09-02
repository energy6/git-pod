require 'rake'

module GitPod

  # This subcommand create a worktree for a pod branch.
  class Checkout < SubCommand  

    # Command
    def self.command
      "checkout"
    end
    
    # Description
    def self.description
      "Create a worktree for pod"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.arg("<name>", "Pod to create worktree for")

        opts.on("-b", "--branch [NAME]", "Select branch, default master") do |v|
          @options[:branch] = v
        end
        
      end
    end

    def exec
      super do        
        raise SubCommandException, "One pod name must be given" if @args.size != 1

        pod = Pod.new(@args[0])
        branch = @options[:branch] || "master"

        worktree = pod.checkout(branch)
        puts "Created new worktree for #{pod.name}@#{branch} in #{worktree.dir}"
      end
    end
        
  end
end

