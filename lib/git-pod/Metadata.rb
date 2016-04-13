module GitModule
  class Metadata
  
    def self.filename
      ".gitmodule"
    end
    
    def self.default(name, desc: "(no description)")
      { name => { :desc => desc } }
    end
    
    def self.create_file(name, desc: "(no description)")
      File.open(filename, 'w+') do |file|
        file.puts default(name, desc: desc).to_yaml
      end
    end
    
    def initialize(branch)
      @branch = branch
      reload
    end
    
    def reload
      if @branch.gcommit.gtree.files.has_key?(self.class.filename)
        @metadata = YAML.load(@branch.gcommit.gtree.files[self.class.filename].contents)
      else
        @metadata = {}
      end
    end
    
    def has_module?(name)
      @metadata.has_key?(name)
    end
    
    def description(name)
      m = @metadata[name] || self.class.default(name)
      return m[:desc] 
    end

    def update(name, desc: nil)
      @branch.in_temp("Changed metadata for module #{@name}") do
        @metadata[name][:desc] = desc if desc
        File.open(self.class.filename, 'w+') do |file|
          file.puts @metadata.to_yaml 
        end
        return true
      end
    end
    
  end
end
