module GitModule
  class List < SubCommand
    def self.command
      "list"
    end
    
    def self.description
      "List all available modules"
    end
 
    def initialize args
       super(args) do |opts|
        
        opts.arg("[name ...]", "Names (patterns) of module to filter")

        opts.on("-u", "--[no-]used", "Show only modules (not) used on the active branch") do |v|
          @options[:used] = v
        end
        
      end
    end
    
    def exec
      super do
        ms = Module.all    
        ms.select!{ |m| @args.any?{ |a| m.name =~ /#{a}/ } } if @args.size > 0
        ms.select!{ |m| m.used? == @options[:used] } if @options.has_key?(:used)
        
        ms.each do |m|
          puts "  %-10s  %s\n" % [ m.name, m.description ]
        end      
      end
    end

  end
end
