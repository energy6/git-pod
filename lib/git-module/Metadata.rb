module GitModule
  class Metadata
  
    def self.filename(name)
      ".#{name}.gitmodule"
    end
    
    def self.default(name, desc: "(no description)")
      { name => { :desc => desc } }
    end
    
    def self.create_file(name, desc: "(no description)")
      File.open(filename(name), 'w+') do |file|
        file.puts default(name, desc: desc).to_yaml
      end
      return filename(name)
    end

    def self.exists?(name)
      File.exists? filename(name)
    end
    
    def initialize(name, branch)
      @name = name
      @branch = branch
      reload
    end
    
    def reload
      if @branch.gcommit.gtree.files.has_key?(self.class.filename(@name))
        @metadata = YAML.load(@branch.gcommit.gtree.files[self.class.filename(@name)].contents)
      else
        @metadata = {}
      end
    end
        
    def description
      m = @metadata[@name] rescue self.class.default(@name)
      return m[:desc] 
    end

    def description=(desc)
      update(desc: desc)
    end

    def update(desc: nil)
      @branch.in_temp("Changed metadata for module #{@name}") do
        @metadata[@name][:desc] = desc if desc
        File.open(self.class.filename(@name), 'w+') do |file|
          file.puts @metadata.to_yaml 
        end
        return true
      end
    end
    
  end
end
