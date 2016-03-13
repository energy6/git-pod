module GitModule
  class Upgrade < SubCommand
    def self.command
      "upgrade"
    end
    
    def self.description
      "Upgrade used modules to latest version"
    end
 
    def initialize args
       super(args) do |opts|
        
        opts.arg("[<name> ...]", "Name(s) of module(s) to be upgraded")
        
      end
    end
    
    def exec
      super do
        ms = Module.all
        ms.select!{ |m| m.used? }
        ms.select!{ |m| @args.any?{ |a| m.name =~ /#{a}/ } } if @args.size > 0
        
        repo = Git.open(Dir.pwd)
        branches = ms.collect{ |m| [ m.name, Module.branch_name(m.name) ] }

        branches.to_h().each do |n, b|
          repo.merge(b, :message => "Update module #{n}.")
        end
      end      
    end

  end
end
