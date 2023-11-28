require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'models'
  t.libs << 'error'
  t.test_files = FileList['test/**/*_test.rb']
end
