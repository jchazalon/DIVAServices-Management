# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks


RDoc::Task.new :rdoc do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "app/**/*.rb", "lib/*.rb", "lib/**/*.rb", "config/**/*.rb") #"doc/*.rdoc"
  rdoc.title = "DIVAServices-Algorithm Documentation"
  rdoc.options << "--all"
  rdoc.options << "--overwrite"
end
