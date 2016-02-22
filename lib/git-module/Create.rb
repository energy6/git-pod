require_relative 'SubCommand.rb'

module GitModule
  class Create < SubCommand  
    def self.command
      "create"
    end
    
    def self.description
      "Create a new module"
    end
    
    def initialize args
      super(args)
    end
        
    def exec
      super()
      return 0
    end
        
  end
end
