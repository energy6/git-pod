module GitModule
  class List < SubCommand
    def self.command
      "list"
    end
    
    def self.description
      "List all available modules"
    end
 
    def exec
      super()
      
      ms = Module.all
      
      ms.select! { |m| @args.contain? m.name } if @args.size > 0
      
      ms.each do |m|
        puts "  %-10s  %s\n" % [ m.name, m.description ]
      end
      
      return 0
    end

  end
end
