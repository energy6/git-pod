require 'git'

module Git
  class Lib
    def checkout(branch, opts = {})
      arr_opts = []
      arr_opts << '-b' if opts[:new_branch] || opts[:b]
      arr_opts << '--force' if opts[:force] || opts[:f]
      arr_opts << '--orphan' if opts[:orphan]
      arr_opts << branch
      
      command('checkout', arr_opts)
    end

    def merge(branch, opts = {})
      arr_opts = []
      arr_opts << '-m' << opts[:message] if opts[:message]
      arr_opts << '--no-commit' if opts[:no_commit]
      arr_opts << '--squash' if opts[:squash]
      arr_opts += [branch]
      command('merge', arr_opts)
    end

    def worktree_add(path, branch = nil, opts = {})
      arr_opts = []
      arr_opts << 'add'
      arr_opts << '-f' if opts[:force]
      arr_opts << '-b' << opts[:branch] if opts[:branch]
      arr_opts += [path]
      arr_opts += [branch] if branch
      command('worktree', arr_opts)
    end

    def worktree_prune(opts = {})
      arr_opts = []
      arr_opts << 'prune'
      arr_opts << '--expire' << opts[:expire] if opts[:expire]
      command('worktree', arr_opts)
    end
  end
  
  class Base
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

    def merge(branch, opts = { :message => 'merge' })
      self.lib.merge(branch, opts)
    end

    def with_temp(&blk)
      oldb = current_branch
      
      with_temp_index do
        with_temp_working do
          yield
        end
      end
      
      checkout oldb
    end

    def new_worktree(path, branch = nil, opts = {})
      self.lib.worktree_add(path, branch, opts) unless Dir.exists?(path)
      self.class.new({:working_directory => path})
    end

    def worktree_prune(opts = {})
      self.lib.worktree_prune(opts)
    end
  end
  
  class Branch
    def in_temp(message = 'in branch work')
      @base.with_temp do
        if yield
          @base.commit_all(message)
        else
          @base.reset_hard
        end
      end
    end

    def new_worktree(path, opts = {})
      @base.new_worktree(path, full, opts)
    end
  end
end
