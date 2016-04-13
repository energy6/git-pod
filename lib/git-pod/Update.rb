module GitPod
  class Update < SubCommand
    def self.command
      "update"
    end
    
    def self.description
      "Update pod meta data"
    end
 
    def initialize args
       super(args) do |opts|
        
        opts.arg("<name>", "Name of pod to update")

        opts.on("-d DESC", "--desc=DESC", "Set pod description to DESC") do |v|
          @options[:desc] = v
        end
        
      end
    end
    
    def exec
      super do
        raise SubCommandException, "A single pod name needed" if @args.size != 1
        m = Pod.new(@args[0])
        m.description = @options[:desc] if @options.has_key?(:desc)
      end      
    end

  end
end
