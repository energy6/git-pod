Gem::Specification.new do |s|
  s.name        = 'git-module'
  s.version     = '0.1.0'
  s.date        = '2016-02-20'
  s.summary     = "Git module command to manage modularized projects."
  s.description = "..."
  s.authors     = ["Jonatan Antoni"]
  s.email       = 'jantoni@web.de'
  s.files       = ["lib/git-module.rb"]
  s.executables << 'git-module'
  s.homepage    =
    'http://rubygems.org/gems/git-module'
  s.license       = 'MIT'
  s.add_runtime_dependency 'git', '~> 1.2', '>= 1.2.9'
end

