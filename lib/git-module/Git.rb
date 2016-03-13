require 'git'

module Git

  module LibExtension
    def log_common_options(opts)
      arr_opts super(opts)

      arr_opts << "--cherry" if opts[:cherry]

      return arr_ops
    end  
  end

  class Lib
    include LibExtension
    
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

    def merge_base(commitishs = [ 'HEAD' ], opts = {})
      commitishs = [ commitishs ] unless commitishs.kind_of?(Array)

      arr_opts = []
      arr_opts += commitishs      
      command('merge-base', arr_opts)
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

    def run_command(git_cmd, &block)
      return IO.popen(git_cmd, "r+", &block) if block_given?
      
      `#{git_cmd}`.chomp
    end  
  end
    
  module FactoryExtension
    def merge_base(commitishs = [ 'HEAD' ], opts = {})      
      Git::Object::Commit.new(self, self.lib.merge_base(commitishs, opts))
    end
  end

  class Base
    include FactoryExtension

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

    def apply_diff(diff)
      self.lib.apply_patch(diff.patch())
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

  class Log
    def cherry()
      dirty_log
      @cherry = true
      return self
    end

    private
  
      def run_log      
        log = @base.lib.full_log_commits(:count => @count, :object => @object, 
                                    :path_limiter => @path, :since => @since, 
                                    :author => @author, :grep => @grep, :skip => @skip,
                                    :until => @until, :between => @between, :cherry => @cherry)
        @commits = log.map { |c| Git::Object::Commit.new(@base, c['sha'], c) }
      end

  end
end
