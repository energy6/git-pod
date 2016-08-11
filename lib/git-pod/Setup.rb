module GitPod
  class Setup < SubCommand
    def self.command
      "setup"
    end
    
    def self.description
      "Configures the current repository to be used with git-pod."
    end
 
    def initialize args
      super(args) do |opts|       
      end
    end
    
    def exec
      # super do
      #   repo = Git.open(Dir.pwd)
      #   repo.config("merge.gitpod.name", "Merge driver for git-pod metadata")
      #   repo.config("merge.gitpod.driver", "gitpod-merge %O %A %B %L %P")
      #   repo.config("merge.gitpod.recursive", "binary")
      #   repo.config("merge.gitpod.trustexitcode", true)
        
      #   File.open(File.join(repo.repo.path, "info", "attributes"), "a+") do |file|
      #     content = file.read
      #     file.puts "#{Metadata::filename}\tmerge=gitpod" unless content =~ /^#{Metadata::filename}\s+/
      #   end
      #    
      #   return 0
      # end
    end

  end
end
