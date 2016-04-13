require 'rake'

module GitPod
  class Migrate < SubCommand  
    def self.command
      "migrate"
    end
    
    def self.description
      "Migrate changes to pods"
    end
    
    def initialize(args)
      super(args) do |opts|
        opts.arg("[<pod> ...]", "Only changes to selected pods are migrated")

        opts.on("-b", "--branch [NAME]", "Pod branch to migrate changes to") do |v|
          @options[:branch] = v
        end
        
      end
    end

    def exec
      super do        
        ms = Pod.all    
        ms.select!{ |m| m.used? } 
        ms.select!{ |m| @args.any?{ |a| m.name =~ /#{a}/ } } if @args.size > 0
        ms.each do |m|
          puts "Migrating changes to #{m.name}"
          m.migrate(@options[:branch] || "master")
        end
      end
    end
        
  end
end

