require 'rake'

module GitPod
  def self.version
    describe = `git describe`
    splitted = describe.split '-'
    if splitted.size > 1
      splitted[0] + ".p" + splitted[1]
    else
      splitted.first
    end
   end
end

Gem::Specification.new do |s|
  s.name        = 'git-pod'
  s.version     = GitPod.version
  s.date        = '2016-04-13'
  s.summary     = "Git pod command to manage modularized projects."
  s.description = "..."
  s.authors     = [ "Jonatan Antoni" ]
  s.email       = 'jantoni@web.de'
  s.files       = [ "lib/git-pod.rb" ]
  s.files       += Rake::FileList["lib/git-pod/*.rb"]
  s.executables << 'git-pod'
  s.executables << 'gitpod-merge'
  s.homepage    =
    'http://rubygems.org/gems/git-pod'
  s.license       = 'MIT'
  s.add_runtime_dependency 'git', '~> 1.2', '>= 1.2.9'
end

