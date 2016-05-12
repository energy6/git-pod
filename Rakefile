require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'

CLEAN << FileList['pkg']

Rake::TestTask.new do |t|
  t.libs << 'test'
end
