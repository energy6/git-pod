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
  end
  
  class Base
    def with_temp(&blk)
      oldb = current_branch
      
      with_temp_index do
        with_temp_working do
          yield
        end
      end
      
      checkout oldb
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
  end
end
