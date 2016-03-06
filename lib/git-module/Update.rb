module GitModule
  class Update < SubCommand
    def self.command
      "update"
    end
    
    def self.description
      "Updates a module"
    end
 
    def initialize args
       super(args) do |opts|
        
        opts.arg("<name>", "Name of module to update")

        opts.on("-d DESC", "--desc=DESC", "Set module description to DESC") do |v|
          @options[:desc] = v
        end
        
      end
    end
    
    def exec
      super do
        raise SubCommandException, "A single module name needed" if @args.size != 1
        m = Module.new(@args[0])
        m.description = @options[:desc] if @options.has_key?(:desc)
      end      
    end

  end
end
