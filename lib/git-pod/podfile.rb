require 'git'

module GitPod
  class ConfigurationError<RuntimeError
  end

  module DSL
    def pod name,remote="podsource"
      #When remote is missing, blow
      remote_branch="/pod/#{name}"
    end
  end
  #The pod file (by default ./pods.rb) lists the pods we want to fetch
  #
  class PodRegistry
    include DSL
    def initialize podfile
      if File.exist?(podfile)
        @raw=File.read(podfile)
      else
        raise ConfigurationError,"Missing pod file #{podfile}"
      end
    end

    def parse
      begin
        eval(File.read(podfile),binding)
      rescue ConfigurationError
      end
    end
  end
end
