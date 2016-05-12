# -*- ruby -*-
Rake.application.options.suppress_backtrace_pattern = /\.gem|ruby-2\.\d+\.\d+/
require "hoe"
require_relative "lib/git-pod/Version"

# Hoe.plugin :minitest
# Hoe.plugin :rcov
# Hoe.plugin :rdoc

Hoe.spec "git-pod" do |prj|

  prj.developer("Jonata Antoni", "jan@zuehlke.com")
  prj.license "MIT" # this should match the license in the README
  prj.version = GitPod::Version::STRING
  prj.summary='Repository dependency management'
  prj.urls=["http://github.com/elixir6/git-pod"]
  prj.description=prj.paragraphs_of('README.md',1..5).join("\n\n")
  prj.local_rdoc_dir='doc/rdoc'
  prj.readme_file="README.md"
  prj.extra_deps<<["git","~>1.2.9"]
  prj.spec_extras={:executables=>["git-pod","gitpod-merge"],:default_executable=>"git-pod"}
end

# vim: syntax=ruby
