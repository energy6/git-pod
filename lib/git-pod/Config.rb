require 'git'

module GitPod
  class Config
    def initialize
      @repo = Git.open(Dir.pwd)
    end
  end
end
