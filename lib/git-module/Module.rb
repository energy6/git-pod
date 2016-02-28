require 'yaml'

module GitModule
  class ModuleException < GitModuleException
  end

  class Module
    def self.create(name, desc)
      repo = Git.open(Dir.pwd)
      bname = branch_name(name, "master")
      raise ModuleException.new("A module with name '#{name}' already exists!") if repo.is_branch?(bname)
      
      repo.with_temp do
        repo.checkout(bname, :orphan => true)
        File.open(gitmodule, 'w+') { |file| file.puts metadata(name, desc).to_yaml }
        repo.add(gitmodule)
        repo.commit("Initial new module #{name}")
      end
      
      return Module.new(name)
    end
    
    def self.remove(name)
      repo = Git.open(Dir.pwd)
      repo.branches.select{ |b| b.name =~ branch_pattern }.each do |b|
        b.delete
      end
    end
    
    def self.metadata(name, desc = nil)
      { name => desc || "(no description)" }
    end
    
    def self.gitmodule
      ".gitmodule"
    end
    
    def self.branch_name(name, branch = "master")
      "modules/#{name}/#{branch}"    
    end
    
    def self.branch_pattern(branch = "master")
      /modules\/(\w+)\/#{branch}/
    end
    
    def self.all
      repo = Git.open(Dir.pwd)
      repo.branches.select{ |b| b.name =~ branch_pattern }.collect{ |b| Module.new(b.name[branch_pattern, 1]) }
    end
    
    def initialize(name)
      @name = name
      @repo = Git.open(Dir.pwd)
      raise ModuleException.new("No module '#{name}' found!") unless @repo.is_branch?(self.class.branch_name(name))
      @master = @repo.branch(self.class.branch_name(name))
    end
    
    def metadata
      if @master.gcommit.gtree.files.has_key?(self.class.gitmodule)
        return YAML.load(@master.gcommit.gtree.files[self.class.gitmodule].contents)
      else 
        return self.class.metadata(@name)
      end
    end
    
    def name
      @name
    end
    
    def description
      return metadata[@name] if metadata.has_key?(@name)
      return "(no description)"
    end

    def description=(desc)
      @repo.with_temp do
        @master.checkout
        File.open(self.class.gitmodule, 'w+') do |file|
          m = metadata
          m[@name] = desc
          file.puts m.to_yaml 
        end
        @repo.add(self.class.gitmodule)
        @repo.commit("Changed description for module #{@name}")
      end
    end
  end
end
