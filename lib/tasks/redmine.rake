require "rspec/core/rake_task"

# Clear core's redmine:plugins:test task, else it's used
# and our own version is never triggered
Rake::Task["redmine:plugins:test"].clear

namespace :redmine do
  namespace :plugins do
    desc "Runs the plugins tests."
    task :test do
      if !ENV["NAME"] || File.exists?(Rails.root.join("plugins/#{ENV["NAME"]}/spec"))
        Rake::Task["redmine:plugins:spec"].invoke
      end
      Rake::Task["redmine:plugins:test:units"].invoke
      Rake::Task["redmine:plugins:test:functionals"].invoke
      Rake::Task["redmine:plugins:test:integration"].invoke
    end

    desc "Runs the plugins specs."
    RSpec::Core::RakeTask.new :spec => "db:test:prepare" do |t|
      #current plugin (or all) spec/ directory
      plugin_dir = "plugins/#{ENV["NAME"] || "*"}"
      spec_dirs = Dir.glob("#{plugin_dir}/spec")
      #add our spec/ directory to the path so other plugins can simply
      #put this on top of their spec:
      #
      #   require "spec_helper"
      #
      spec_dirs << File.expand_path("../../../spec", __FILE__)
      #which specs to run
      t.pattern = "#{plugin_dir}/spec/**/*_spec.rb"
      #which LOAD_PATH (for spec_helper especially)
      t.ruby_opts = "-I#{spec_dirs.join(":")}"
    end
  end
end
