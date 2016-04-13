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
        opts.on("-p", "--pod NAME", "Pod to commit changes to") do |v|
          @options[:pod] = v
        end

        opts.on("-b", "--branch [NAME]", "Pods branch to commit changes to") do |v|
          @options[:branch] = v
        end
        
      end
    end

    def exec
      super do        
        raise SubCommandException, "Pod must be given" unless @options[:pod]

        mod = Pod.new(@options[:pod])
        branch = @options[:branch] || "master"

        mod.status(branch)
      end
    end
        
  end
end

