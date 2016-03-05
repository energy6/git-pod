module GitModule
  class Update < SubCommand
    def self.command
      "select"
    end
    
    def self.description
      "Select modules to be used"
    end
 
    def initialize args
       super(args) do |opts|
        
        opts.arg("<name> [name ...]", "Name(s) of module(s) to be selected")
        
      end
    end
    
    def exec
      super()
      ms = Module.all      
      ms.select!{ |m| (not m.used?) && @args.any?{ |a| m.name =~ /#{a}/ } } if @args.size > 0
      
      repo = Git.open(Dir.pwd)
      branches = ms.collect{ |m| [ m.name, Module.branch_name(m.name) ] }

      branches.to_h().each do |n, b|
        repo.merge(b, :message => "Select module #{n}.")
      end

      return 0
    end

  end
end
