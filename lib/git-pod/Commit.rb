require 'rake'

module GitPod
  class Commit < SubCommand  
    def self.command
      "commit"
    end
    
    def self.description
      "Commits currently staged files for pod"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.on("-p", "--pod NAME", "Pod to commit changes to") do |v|
          @options[:pod] = v
        end

        opts.on("-b", "--branch [NAME]", "Pods branch to commit changes to") do |v|
          @options[:branch] = v
        end

        opts.on("-m", "--message MSG", "Commit message") do |v|
          @options[:cmessage] = v
        end
        
      end
    end

    def exec
      super do        
        raise SubCommandException, "Pod must be given" unless @options[:pod]
        raise SubCommandException, "Commit message must be given" unless @options[:cmessage]

        mod = Pod.new(@options[:pod])
        branch = @options[:branch] || "master"

        mod.commit(branch, @options[:cmessage])
      end
    end
        
  end
end

