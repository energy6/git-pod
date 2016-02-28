require 'git'

module GitModule
  class Config
    def initialize
      @repo = Git.open(Dir.pwd)
    end
  end
end
