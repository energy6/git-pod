module GitPod
  class Remove < SubCommand
    def self.command
      "remove"
    end
    
    def self.description
      "Remove a pod"
    end

    def initialize(args)
      super(args) do |opts|
        opts.arg("<pod> [<pod> ...]", "Selected pods are removed")
      end
    end

    def exec
      super do
        raise SubCommandException, "No pods given!" unless @args.size > 0
        # TODO: Sicherheitsabfrage
        @args.each { |p|  Pod.remove(p) }
      end
    end

  end
end
