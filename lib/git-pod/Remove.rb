module GitPod
  class Remove < SubCommand
    def self.command
      "remove"
    end
    
    def self.description
      "Remove a pod"
    end

    def exec
      super do
        raise SubCommandException, "No pod name given" unless @args.size == 1
        # TODO: Sicherheitsabfrage
        Pod.remove(@args[0])
      end
    end

  end
end
