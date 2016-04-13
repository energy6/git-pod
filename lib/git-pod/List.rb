module GitPod
  class List < SubCommand
    def self.command
      "list"
    end
    
    def self.description
      "List all available pods"
    end
 
    def initialize args
       super(args) do |opts|
        
        opts.arg("[name ...]", "Names (patterns) of pod to filter")

        opts.on("-u", "--[no-]used", "Show only pods (not) used on the active branch") do |v|
          @options[:used] = v
        end
        
      end
    end
    
    def exec
      super do
        ms = Pod.all    
        ms.select!{ |m| @args.any?{ |a| m.name =~ /#{a}/ } } if @args.size > 0
        ms.select!{ |m| m.used? == @options[:used] } if @options.has_key?(:used)
        
        if ms.size > 0
          ms.each do |m|
            puts "  %-10s  %s\n" % [ m.name, m.description ]
          end      
        else
          puts "No pods available."
        end
      end
    end

  end
end
