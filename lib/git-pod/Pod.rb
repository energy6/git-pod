require 'yaml'

module GitModule

  # Module operation exception
  class ModuleException < GitModuleException
  end

  # Abstraction for a single module
  # A module is a orphan branch in the git repo. Also branches of a module are
  # possible, which are just branches based on the initial orphan module master.
  # Module branches are distinguished from non-module branches by a simple
  # naming schema, i.e. modules/<module name>/<module branch>.
  #
  # Each module has associated meta information stored in a hidden meta data
  # file, see GitModule::Metadata. The meta data identifies a module with name
  # and additional information.
  class Module
    @zombie = true

    # Create a new module with a given description.
    # A new and empty orphan branch is created according to the naming schema.
    # The description is written to the meta data file along with other initial
    # meta information. The meta data file is committed as the initial commit. 
    #
    # If a module with the given name already exists, a ModuleException is
    # raised.
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
    
    # Remove the named module. All branches related to the module are removed
    # from the repo. The branches to be deleted are selected according to the
    # naming schema. 
    def self.remove(name)
      repo = Git.open(Dir.pwd)
      repo.branches.select{ |b| b.name =~ branch_pattern(name: name) }.each do |b|
        puts "Removing #{b.name}"
        b.delete
      end
      workdir = File.join(@repo.dir.to_s, ".worktree", @name)
      FileUtils.remove_entry_secure(workdir) if Dir.exists?(workdir)
    end
        
    # Returns the exact branch name for the named module and its branch.
    # If no branch is given, it defaults to master. 
    def self.branch_name(name, branch: "master")
      "modules/#{name}/#{branch}"    
    end
    
    # Returns a regex for matching module branches. The created regex can be
    # customized by giving a name and/or a branch pattern. By default all
    # names and branches that matches /\w+/ are taken into account. 
    def self.branch_pattern(name: /(\w+)/, branch: /(\w+)/)
      /modules\/#{name}\/#{branch}/
    end
    
    # Returns an array with Module instances for all availabl modules.
    # A module is recognized as "available", if its master branch exists
    # according to the naming schema.
    def self.all
      repo = Git.open(Dir.pwd)
      pattern = branch_pattern(:branch => "master")
      repo.branches.select{ |b| b.name =~ pattern }.collect{ |b| Module.new(b.name[pattern, 1]) }
    end
    
    # Create a new Module abstraction for the named module.
    #
    # If the module does not exist, i.e. the master branch does not exist, a
    # ModuleException is raised.
    def initialize(name)
      @name = name
      @repo = Git.open(Dir.pwd)
      raise ModuleException, "No module '#{name}' found!" unless @repo.is_branch?(self.class.branch_name(name))
      @master = @repo.branch(self.class.branch_name(name))
      @metadata = Metadata.new(@master)
      @zombie = false
    end
        
    # Returns an array with all existing branches that belong to the module
    # according to the naming schema. 
    def branches
      zombie_check
      pattern = self.class.branch_pattern(:name => @name)
      @repo.branches.select{ |b| b.name =~ pattern }
    end
    
    # Returns the modules name.
    def name
      zombie_check
      @name
    end
  
    # Returns the modules description, see Metadata#description.
    def description
      zombie_check
      @metadata.description(@name)
    end

    # Sets the modules description to a new text, see Metadata#update.
    def description=(desc)
      zombie_check
      @metadata.update(@name, desc: desc)       
    end
    
    # Returns true, if this module is used on the active branch, see
    # Metadata.has_module?
    def used?
      zombie_check
      m = Metadata.new(@repo.branch(@repo.current_branch))
      return m.has_module?(@name)
    end
    
    # Removes this module. This instance must not be used any more after
    # calling this method. 
    # Each subsequent call to this instance will raise a ModuleException.
    def remove!
      zombie_check
      self.class.remove(@name)
    end

    # Yields the given block in a seperate working directory for the named
    # branch of the module. The block is called with the git repo instance to
    # access the worktree. 
    def on_worktree(branch, &block)
      zombie_check      
      yield checkout(branch) 
    end

    # Checkout the named branch in an dedicated worktree.
    # The repo instance to access the worktree is returned.
    def checkout(branch)
      zombie_check
      workdir = File.join(@repo.dir.to_s, ".worktree", @name, branch)
      worktree = @repo.new_worktree(workdir, self.class.branch_name(@name, branch: branch))      
    end

    # Add the given files to the index of the named branch.
    def addFiles(branch, files)
      zombie_check
      on_worktree(branch) do |repo|
        repo.checkout_file(@repo.current_branch, files)
        repo.add(files)
      end
    end

    # Commit all changes to the named module branch. The given message is used
    # as the commit message for the commit.
    def commit(branch, message)
      zombie_check
      on_worktree(branch) { |repo| repo.commit(message) }
    end

    # Prints out the repo status for the named module branch.
    def status(branch)
      zombie_check
      on_worktree(branch) do |repo| 
        puts repo.status.pretty
      end
    end

    # Checks whether a given file or directory is already existing in the module.
    # The search can be performed on a specific branch. By default the master
    # branch is used. 
    def contains?(fileOrDir, branch: "master")
      zombie_check
      b = @repo.branch(self.class.branch_name(@name, branch: branch))
      tree = b.gcommit.gtree
      splits = File.split(fileOrDir)
      splits.shift() if splits[0] == "."
      splits.each do |segment|
        tree = tree.children[segment] unless tree == nil      
      end
      return tree != nil
    end

    # Checks whether the active branch has changed files that belongs to the
    # modules branch, i.e. changes that may be migrated. 
    def has_changes?(branch)
      zombie_check
    end

    # Checks whether the modules branch has changes not yet merged to the
    # active branch, i.e. updates that may be merged.
    def has_update?(branch)
      zombie_check
    end

    # Mirgate all changes from the active branch to the named module branch.
    # All changes to files already available on the target are taken into
    # account. The patches are migrated into the module branches worktree
    # and staged for a later commit, see Module#commit. 
    def migrate(branch)
      zombie_check
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

    private

    # Raises a ModuleException if this instance is a zombie.
    def zombie_check
      raise ModuleException, "This module instance is a zombie!" if @zombie
    end
  end
end
