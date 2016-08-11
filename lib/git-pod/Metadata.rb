module GitPod
  class Metadata
  
    def self.filename(name)
      ".#{name}.gitpod"
    end
    
    def self.default(name, desc: "(no description)")
      { :name => name, :desc => desc }
    end
    
    def self.create_file(name, desc: "(no description)")
      File.open(filename(name), 'w+') do |file|
        file.puts default(name, desc: desc).to_yaml
      end
    end

    def self.has_file?(branch, name)
        branch.gcommit.gtree.files.has_key?(filename(name))
    end
    
    def initialize(name, branch)
      @name = name
      @branch = branch
      reload
    end
    
    def reload
      if self.class.has_file?(@branch, @name) 
        @metadata = YAML.load(@branch.gcommit.gtree.files[self.class.filename(@name)].contents)
      else
        @metadata = {}
      end
    end
        
    def description
      m = @metadata || self.class.default(@name)
      return m[:desc] 
    end

    def update(name, desc: nil)
      @branch.in_temp("Changed metadata for pod #{@name}") do
        @metadata[:desc] = desc if desc
        File.open(self.class.filename(name), 'w+') do |file|
          file.puts @metadata.to_yaml 
        end
        return true
      end
    end
    
  end
end
