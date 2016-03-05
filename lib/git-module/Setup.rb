module GitModule
  class Setup < SubCommand
    def self.command
      "setup"
    end
    
    def self.description
      "Configures the current repository to be used with git-module."
    end
 
    def initialize args
      super(args) do |opts|       
      end
    end
    
    def exec
      super()
      repo = Git.open(Dir.pwd)
      repo.config("merge.gitmodule.name", "Merge driver for git-module metadata")
      repo.config("merge.gitmodule.driver", "gitmodule-merge %O %A %B %L %P")
      repo.config("merge.gitmodule.recursive", "binary")
      
      File.open(File.join(repo.repo.path, "info", "attributes"), "a+") do |file|
        content = file.read
        file.puts "#{Metadata::filename}\tmerge=gitmodule" unless content =~ /^#{Metadata::filename}\s+/
      end
      
      return 0
    end

  end
end
