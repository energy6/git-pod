require 'yaml'

module GitModule
  class ModuleException < GitModuleException
  end

  class Module
    def self.create(name, desc)
      repo = Git.open(Dir.pwd)
      bname = branch_name(name)
      raise ModuleException.new("A module with name '#{name}' already exists!") if repo.is_branch?(bname)
      
      repo.with_temp do
        repo.checkout(bname, :orphan => true)        
        Metadata.create_file(name, desc: desc)
        repo.add(Metadata.filename)
        repo.commit("Initial new module #{name}")
      end
      
      return Module.new(name)
    end
    
    def self.remove(name)
      repo = Git.open(Dir.pwd)
      repo.branches.select{ |b| b.name =~ branch_pattern(name: name) }.each do |b|
        puts "Removing #{b.name}"
        b.delete
      end
    end
        
    def self.branch_name(name, branch: "master")
      "modules/#{name}/#{branch}"    
    end
    
    def self.branch_pattern(name: /(\w+)/, branch: /(\w+)/)
      /modules\/#{name}\/#{branch}/
    end
    
    def self.all
      repo = Git.open(Dir.pwd)
      pattern = branch_pattern(:branch => "master")
      repo.branches.select{ |b| b.name =~ pattern }.collect{ |b| Module.new(b.name[pattern, 1]) }
    end
    
    def initialize(name)
      @name = name
      @repo = Git.open(Dir.pwd)
      raise ModuleException.new("No module '#{name}' found!") unless @repo.is_branch?(self.class.branch_name(name))
      @master = @repo.branch(self.class.branch_name(name))
      @metadata = Metadata.new(@master)
    end
        
    def branches
      pattern = self.class.branch_pattern(:name => @name)
      @repo.branches.select{ |b| b.name =~ pattern }
    end
    
    def name
      @name
    end
  
    def description
      return @metadata.description(@name)
    end

    def description=(desc)
      @metadata.update(@name, desc: desc)       
    end
    
    def used?
      m = Metadata.new(@repo.branch(@repo.current_branch))
      return m.has_module?(@name)
    end
    
    def remove!
      self.class.remove(@name)
    end
  end
end
