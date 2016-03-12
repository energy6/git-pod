require 'rake'

module GitModule
  class Checkout < SubCommand  
    def self.command
      "checkout"
    end
    
    def self.description
      "Create a worktree for module"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.arg("<name>", "Module to create worktree for")

        opts.on("-b", "--branch [NAME]", "Select branch, default master") do |v|
          @options[:branch] = v
        end
        
      end
    end

    def exec
      super do        
        raise SubCommandException, "One module name must be given" if @args.size != 1

        mod = Module.new(@args[0])
        branch = @options[:branch] || "master"

        worktree = mod.checkout(branch)
        puts "Created new worktree for #{mod.name}@#{branch} in #{worktree.dir}"
      end
    end
        
  end
end

