require 'rake'

module GitModule
  class Status < SubCommand  
    def self.command
      "status"
    end
    
    def self.description
      "Status of index for a module"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.on("-m", "--module NAME", "Module to commit changes to") do |v|
          @options[:module] = v
        end

        opts.on("-b", "--branch [NAME]", "Modules branch to commit changes to") do |v|
          @options[:branch] = v
        end
        
      end
    end

    def exec
      super do        
        raise SubCommandException, "Module must be given" unless @options[:module]

        mod = Module.new(@options[:module])
        branch = @options[:branch] || "master"

        mod.status(branch)
      end
    end
        
  end
end

