module GitModule
  class Create < SubCommand  
    def self.command
      "create"
    end
    
    def self.description
      "Create a new module"
    end
    
    def initialize(args)
      super(args) do |opts|
        
        opts.arg("<name>", "Name of module to create")

        opts.on("-d DESC", "--desc=DESC", "Set module description to DESC") do |v|
          @options[:desc] = v
        end
        
      end
    end
        
    def exec
      super()
      usage() unless @args.size == 1
      
      Module.create(@args[0], @options[:desc])
      
      return 0
    end
        
  end
end

