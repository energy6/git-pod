module GitPod
  class Create < SubCommand  
    def self.command
      "create"
    end
    
    def self.description
      "Create a new pod"
    end
    
    def initialize(args)
      super(args) do |opts|
        
        opts.arg("<name>", "Name of pod to create")

        opts.on("-d DESC", "--desc=DESC", "Set pod description to DESC") do |v|
          @options[:desc] = v
        end
        
      end
    end
        
    def exec
      super do
        raise SubCommandException, "No name given." unless @args.size == 1
      
        Pod.create(@args[0], @options[:desc])
      end
    end
        
  end
end

