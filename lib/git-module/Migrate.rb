require 'rake'

module GitModule
  class Migrate < SubCommand  
    def self.command
      "migrate"
    end
    
    def self.description
      "Migrate changes to modules"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.arg("[<module> ...]", "Only changes to selected modules are migrated")

        opts.on("-b", "--branch [NAME]", "Modules branch to add file to") do |v|
          @options[:branch] = v
        end
        
      end
    end

    def exec
      super do        
        ms = Module.all    
        ms.select!{ |m| m.used? == @options[:used] } 
        ms.select!{ |m| @args.any?{ |a| m.name =~ /#{a}/ } } if @args.size > 0
        ms.each do |m|
          
        end
      end
    end
        
  end
end

