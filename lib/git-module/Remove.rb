module GitModule
  class Remove < SubCommand
    def self.command
      "remove"
    end
    
    def self.description
      "Remove a module"
    end

    def exec
      super do
        raise SubCommandException, "No module name given" unless @args.size == 1
        # TODO: Sicherheitsabfrage
        Module.remove(@args[0])
      end
    end

  end
end
