require "bundler/gem_tasks"
require 'rake/testtask'

task :default => [:test]

desc 'Run all test.'
Rake::TestTask.new do |t, args|
  p args
  t.libs << "test"
  t.test_files = Dir["test/**/test_*.rb"]
  t.verbose = true
end
