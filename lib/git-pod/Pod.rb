require 'yaml'

module GitPod

  # Pod operation exception
  class PodException < GitPodException
  end

  # Abstraction for a single pod
  # A pod is a orphan branch in the git repo. Also branches of a pod are
  # possible, which are just branches based on the initial orphan pod master.
  # Pod branches are distinguished from non-pod branches by a simple
  # naming schema, i.e. pods/<pod name>/<pod branch>.
  #
  # Each pod has associated meta information stored in a hidden meta data
  # file, see GitPod::Metadata. The meta data identifies a pod with name
  # and additional information.
  class Pod
    @zombie = true

    # Create a new pod with a given description.
    # A new and empty orphan branch is created according to the naming schema.
    # The description is written to the meta data file along with other initial
    # meta information. The meta data file is committed as the initial commit. 
    #
    # If a pod with the given name already exists, a PodException is
    # raised.
    def self.create(name, desc)
      repo = Git.open(Dir.pwd)
      bname = branch_name(name)
      raise PodException.new("A pod with name '#{name}' already exists!") if repo.is_branch?(bname)
      
      repo.with_temp do
        repo.checkout(bname, :orphan => true)
        repo.reset() 
        Metadata.create_file(name, desc: desc)
        repo.add(Metadata.filename(name))
        repo.commit("Initial new pod #{name}")
      end
      
      return Pod.new(name)
    end
    
    # Remove the named pod. All branches related to the pod are removed
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
        
    # Returns the exact branch name for the named pod and its branch.
    # If no branch is given, it defaults to master. 
    def self.branch_name(name, branch: "master")
      "pods/#{name}/#{branch}"    
    end
    
    # Returns a regex for matching pod branches. The created regex can be
    # customized by giving a name and/or a branch pattern. By default all
    # names and branches that matches /\w+/ are taken into account. 
    def self.branch_pattern(name: /(\w+)/, branch: /(\w+)/)
      /pods\/#{name}\/#{branch}/
    end
    
    # Returns an array with Pod instances for all availabl pods.
    # A pod is recognized as "available", if its master branch exists
    # according to the naming schema.
    def self.all
      repo = Git.open(Dir.pwd)
      pattern = branch_pattern(:branch => "master")
      repo.branches.select{ |b| b.name =~ pattern }.collect{ |b| Pod.new(b.name[pattern, 1]) }
    end
    
    # Create a new Pod abstraction for the named pod.
    #
    # If the pod does not exist, i.e. the master branch does not exist, a
    # PodException is raised.
    def initialize(name)
      @name = name
      @repo = Git.open(Dir.pwd)
      raise PodException, "No pod '#{name}' found!" unless @repo.is_branch?(self.class.branch_name(name))
      @master = @repo.branch(self.class.branch_name(name))
      @metadata = Metadata.new(name, @master)
      @zombie = false
    end
        
    # Returns an array with all existing branches that belong to the pod
    # according to the naming schema. 
    def branches
      zombie_check
      pattern = self.class.branch_pattern(:name => @name)
      @repo.branches.select{ |b| b.name =~ pattern }
    end
    
    # Returns the pods name.
    def name
      zombie_check
      @name
    end
  
    # Returns the pods description, see Metadata#description.
    def description
      zombie_check
      @metadata.description
    end

    # Sets the pods description to a new text, see Metadata#update.
    def description=(desc)
      zombie_check
      @metadata.update(@name, desc: desc)       
    end
    
    # Returns true, if this pod is used on the active branch, see
    # Metadata.has_pod?
    def used?
      zombie_check
      return Metadata.has_file?(@repo.branch(@repo.current_branch), @name)
    end
    
    # Removes this pod. This instance must not be used any more after
    # calling this method. 
    # Each subsequent call to this instance will raise a PodException.
    def remove!
      zombie_check
      self.class.remove(@name)
    end

    # Yields the given block in a seperate working directory for the named
    # branch of the pod. The block is called with the git repo instance to
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

    # Commit all changes to the named pod branch. The given message is used
    # as the commit message for the commit.
    def commit(branch, message)
      zombie_check
      on_worktree(branch) { |repo| repo.commit(message) }
    end

    # Prints out the repo status for the named pod branch.
    def status(branch)
      zombie_check
      on_worktree(branch) do |repo| 
        puts repo.status.pretty
      end
    end

    # Checks whether a given file or directory is already existing in the pod.
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
    # pods branch, i.e. changes that may be migrated. 
    def has_changes?(branch)
      zombie_check
    end

    # Checks whether the pods branch has changes not yet merged to the
    # active branch, i.e. updates that may be merged.
    def has_update?(branch)
      zombie_check
    end

    # Mirgate all changes from the active branch to the named pod branch.
    # All changes to files already available on the target are taken into
    # account. The patches are migrated into the pod branches worktree
    # and staged for a later commit, see Pod#commit. 
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

    # Raises a PodException if this instance is a zombie.
    def zombie_check
      raise PodException, "This pod instance is a zombie!" if @zombie
    end
  end
end
