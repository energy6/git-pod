module GitPod
  class Upgrade < SubCommand
    def self.command
      "upgrade"
    end
    
    def self.description
      "Upgrade used pods to latest version"
    end
 
    def initialize args
       super(args) do |opts|
        
        opts.arg("[<name> ...]", "Name(s) of pod(s) to be upgraded")
        
      end
    end
    
    def exec
      super do
        ms = Pod.all
        ms.select!{ |m| m.used? }
        ms.select!{ |m| @args.any?{ |a| m.name =~ /#{a}/ } } if @args.size > 0
        
        repo = Git.open(Dir.pwd)
        branches = ms.collect{ |m| [ m.name, Pod.branch_name(m.name) ] }

        branches.to_h().each do |n, b|
          repo.merge(b, :message => "Update pod #{n}.")
        end
      end      
    end

  end
end
