require 'rake'

module GitModule
  class Commit < SubCommand  
    def self.command
      "commit"
    end
    
    def self.description
      "Commits currently staged files for module"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.on("-m", "--module NAME", "Module to commit changes to") do |v|
          @options[:module] = v
        end

        opts.on("-b", "--branch [NAME]", "Modules branch to commit changes to") do |v|
          @options[:branch] = v
        end

        opts.on("-c", "--cmessage MSG", "Commit message") do |v|
          @options[:cmessage] = v
        end
        
      end
    end

    def exec
      super do        
        raise SubCommandException, "Module must be given" unless @options[:module]
        raise SubCommandException, "Commit message must be given" unless @options[:cmessage]

        mod = Module.new(@options[:module])
        branch = @options[:branch] || "master"

        mod.commit(branch, @options[:cmessage])
      end
    end
        
  end
end

