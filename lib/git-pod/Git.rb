require 'git'

module Git

  # Extension mix-ins for Git::Lib
  module LibExtension
    # Enhancement to Git::Lib#log_common_options to provide further options. 
    def log_common_options(opts)
      arr_opts super(opts)

      arr_opts << "--cherry" if opts[:cherry]

      return arr_ops
    end  
  end

  # Monkey patch for Git::Lib
  class Lib
    include LibExtension
    
    # Applies a patch given as a string parameter.
    def apply_patch(patch)
      arr_opts = []
      arr_opts << '-3'
      arr_opts << '-'

      Dir.chdir(@git_work_dir) do 
        command('apply', arr_opts) do |io|
          io.puts(patch)
        end
      end
    end

    # Enhance the original Git::Lib#checkout method with the
    # orphan option.
    def checkout(branch, opts = {})
      arr_opts = []
      arr_opts << '-b' if opts[:new_branch] || opts[:b]
      arr_opts << '--force' if opts[:force] || opts[:f]
      arr_opts << '--orphan' if opts[:orphan]
      arr_opts << branch
      
      command('checkout', arr_opts)
    end

    # Enhances the original Git::Lib#merge method with no-commit and squash
    # options.
    def merge(branch, opts = {})   
      arr_opts = []
      arr_opts << '-m' << opts[:message] if opts[:message]
      arr_opts << '--no-commit' if opts[:no_commit]
      arr_opts << '--squash' if opts[:squash]
      arr_opts << '--allow-unrelated-histories' if opts[:unrelated]
      arr_opts += [branch]
      command('merge', arr_opts)
    end

    # Find the common merge base for an array of commits.
    def merge_base(commitishs = [ 'HEAD' ], opts = {})
      commitishs = [ commitishs ] unless commitishs.kind_of?(Array)

      arr_opts = []
      arr_opts += commitishs      
      command('merge-base', arr_opts)
    end

    # Creates a new worktree at a given path location.
    # If no branch is given the active branch is used as a reference.
    def worktree_add(path, branch = nil, opts = {})
      arr_opts = []
      arr_opts << 'add'
      arr_opts << '-f' if opts[:force]
      arr_opts << '-b' << opts[:branch] if opts[:branch]
      arr_opts += [path]
      arr_opts += [branch] if branch
      command('worktree', arr_opts)
    end

    # Removes outdated worktrees.
    def worktree_prune(opts = {})
      arr_opts = []
      arr_opts << 'prune'
      arr_opts << '--expire' << opts[:expire] if opts[:expire]
      command('worktree', arr_opts)
    end

    # Enhances/fixes the original Git::Lib#run_command method such that the
    # IO.popen is executed for read-write access in order to be able to send
    # data to the process thru its STDIN.
    def run_command(git_cmd, &block)
      return IO.popen(git_cmd, "r+", &block) if block_given?
      
      `#{git_cmd}`.chomp
    end  
  end
   
  # Extension mix-ins to the Git::Base::Factory 
  module FactoryExtension
    # Create an instance of Git::Object::Commit for the merge base of the
    # given commits.
    def merge_base(commitishs = [ 'HEAD' ], opts = {})      
      Git::Object::Commit.new(self, self.lib.merge_base(commitishs, opts))
    end
  end

  # Monkey patch for the original Git::Base class.
  class Base
    include FactoryExtension

    # Enhancement/fix to the original Git::Base.initialize method in order
    # to allow an instance to represent a primary git repo (with a .git
    # directory) as well as a secondary repo (with just .git file pointing to
    # the real .git directory). This is needed to handle subpods and
    # worktrees.
    def initialize(options = {})
      if working_dir = options[:working_directory]
        git_dir = File.join(working_dir, '.git')
        if File.file?(git_dir)
          git_file = File.open(git_dir).read[8..-1].strip
          options[:repository] = git_file
          options[:index] ||= File.join(git_file, 'index')
        else
          options[:repository] ||= git_dir
          options[:index] ||= File.join(git_dir, 'index')
        end
      end
      if options[:log]
        @logger = options[:log]
        @logger.info("Starting Git")
      else
        @logger = nil
      end
     
      @working_directory = options[:working_directory] ? Git::WorkingDirectory.new(options[:working_directory]) : nil
      @repository = options[:repository] ? Git::Repository.new(options[:repository]) : nil 
      @index = options[:index] ? Git::Index.new(options[:index], false) : nil
    end

    # Apply the given diff directly to the file system.
    def apply_diff(diff)
      self.lib.apply_patch(diff.patch())
    end

    # Changing the interface of the original Git::Base.merge method to include
    # the merge commit message within the common opts hash.
    def merge(branch, opts = { :message => 'merge' })
      self.lib.merge(branch, opts)
    end

    # Combination of Git::Base.with_temp_index and
    # Git::Base.with_temp_working
    # Yields the block on a temporary working directory
    # with a temporary git index.
    def with_temp(&blk)
      oldb = current_branch
      
      with_temp_index do
        with_temp_working do
          yield
        end
      end
      
      checkout oldb
    end

    # Create a new worktree at the given path location.
    def new_worktree(path, branch = nil, opts = {})
      self.lib.worktree_add(path, branch, opts) unless Dir.exists?(path)
      self.class.new({:working_directory => path})
    end

    # Prunes out old worktrees
    def worktree_prune(opts = {})
      self.lib.worktree_prune(opts)
    end
  end
  
  # Mokey patch to original Git::Branch class.
  class Branch

    # Do some seperated work, see Git::Base::with_temp.
    # If the given block returns true, all changes are committed using the
    # given message. Otherwise all changes are reverted by a hard reset. 
    def in_temp(message = 'in branch work')
      @base.with_temp do
        if yield
          @base.commit_all(message)
        else
          @base.reset_hard
        end
      end
    end

    # Create a new worktree for this branch at the given path location.
    def new_worktree(path, opts = {})
      @base.new_worktree(path, full, opts)
    end
  end

  # Mokey patch to the original Git::Log class.
  # This patch enhances the log with the cherry option.
  class Log

    # Sets the cherry flag.
    def cherry()
      dirty_log
      @cherry = true
      return self
    end

    private
  
      # Execute the log command.
      def run_log      
        log = @base.lib.full_log_commits(:count => @count, :object => @object, 
                                    :path_limiter => @path, :since => @since, 
                                    :author => @author, :grep => @grep, :skip => @skip,
                                    :until => @until, :between => @between, :cherry => @cherry)
        @commits = log.map { |c| Git::Object::Commit.new(@base, c['sha'], c) }
      end

  end
end
