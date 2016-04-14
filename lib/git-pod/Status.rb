require 'rake'

module GitPod
  class Status < SubCommand  
    def self.command
      "status"
    end
    
    def self.description
      "Status of index for a pod"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.arg("<pod> ", "Pod to give status for")

        opts.on("-b", "--branch [NAME]", "Pods branch to state, defaults to master") do |v|
          @options[:branch] = v
        end
        
      end
    end

    def exec
      super do        
        raise SubCommandException, "One pod name must be given" unless @args.size == 1

        mod = Pod.new(@args[0])
        branch = @options[:branch] || "master"

        mod.status(branch)
      end
    end
        
  end
end

