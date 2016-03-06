require 'rake'

module GitModule
  class Add < SubCommand  
    def self.command
      "add"
    end
    
    def self.description
      "Add files to a module's index"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.arg("<file> [<file> ...]", "Files to be added to the module's index")

        opts.on("-m", "--module NAME", "Module to add the file to") do |v|
          @options[:module] = v
        end

        opts.on("-b", "--branch [NAME]", "Modules branch to add file to") do |v|
          @options[:branch] = v
        end
        
      end
    end

    def exec
      super do        
        raise SubCommandException, "Module must be given" unless @options[:module]
        raise SubCommandException, "No files given" if @args.size < 1

        mod = Module.new(@options[:module])

        branch = @options[:branch] || "master"        
        files = @args.collect{ |a| Rake::FileList[a] }.flatten!

        mod.addFiles(branch, files)
      end
    end
        
  end
end

