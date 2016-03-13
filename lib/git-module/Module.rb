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
        repo.reset() 
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
      workdir = File.join(@repo.dir.to_s, ".worktree", @name)
      FileUtils.remove_entry_secure(workdir) if Dir.exists?(workdir)
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
      raise ModuleException, "No module '#{name}' found!" unless @repo.is_branch?(self.class.branch_name(name))
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

    def on_worktree(branch, &block)      
      yield checkout(branch) 
    end

    def checkout(branch)
      workdir = File.join(@repo.dir.to_s, ".worktree", @name, branch)
      worktree = @repo.new_worktree(workdir, self.class.branch_name(@name, branch: branch))      
    end

    def addFiles(branch, files)
      on_worktree(branch) do |repo|
        repo.checkout_file(@repo.current_branch, files)
        repo.add(files)
      end
    end

    def commit(branch, message)
      on_worktree(branch) { |repo| repo.commit(message) }
    end

    def status(branch)
      on_worktree(branch) do |repo| 
        puts repo.status.pretty
      end
    end

    def contains?(fileOrDir, branch: "master")
      b = @repo.branch(self.class.branch_name(@name, branch: branch))
      tree = b.gcommit.gtree
      splits = File.split(fileOrDir)
      splits.shift() if splits[0] == "."
      splits.each do |segment|
        tree = tree.children[segment] unless tree == nil      
      end
      return tree != nil
    end

    def migrate(branch)
      b = @repo.branch(self.class.branch_name(@name, branch: branch))
      base = @repo.merge_base(['HEAD', b])
      diff = @repo.diff(base, @repo.current_branch)
      files = diff.stats[:files].keys() \
        .delete_if{ |f| File.split(f).any?{ |ff| ff != "." &&  ff.start_with?('.') } } \
        .keep_if{ |f| contains?(f, branch: branch) }
      files.each do |file|
        puts "  Patching file #{file}"
        on_worktree(branch) do |repo|
          repo.apply_diff(diff[file])
          repo.add(file)
        end
      end
    end
  end
end
