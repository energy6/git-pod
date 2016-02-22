require_relative 'SubCommand.rb'

module GitModule
  class Remove < SubCommand
    def self.command
      "remove"
    end
    
    def self.description
      "Remove a module"
    end

    def exec
      return 0
    end

  end
end
