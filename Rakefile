require 'yaml'
REMOTE_CHEF_PATH = "/etc/chef" # Where to find upstream cookbooks

def server_config_env
  if !ENV["server"]
    puts "No server given checking for defaults..."
    File.open(File.dirname(__FILE__) + '/server.yml') do |file|
      yaml = YAML.load(file)
    end
    yaml = yaml['server']
    if(yaml['user'] && yaml['host'])
      ENV['server'] = yaml['user'] + '@' + yaml['host']
    else
      puts "When using the default you must create a server.yml see server.yml.tpl"
      exit 1
    end
  end  
end

def ssh_command(command)
  puts "Remotely running #{command.inspect}"
  sh "ssh #{ENV['server']} \"#{command}\""
end

namespace :chef do
  
  task :environemnt do
    server_config_env    
  end

  desc "Test your cookbooks and config files for syntax errors"
  task :test do
    Dir[ File.join(File.dirname(__FILE__), "**", "*.rb") ].each do |recipe|
      sh %{ruby -c #{recipe}} do |ok, res|
        raise "Syntax error in #{recipe}" if not ok
      end
    end

  end

  desc "Installs required gems (assumes ruby and required libraries for chef)" 
  task :install => :environment do
    ssh_command "sudo gem install ohai chef"
  end
  
  
  desc "Upload the latest copy of your cookbooks to remote server"
  task :upload => :environment do
    puts "* Upload your cookbooks *"
    sh "rsync -rlP --delete --exclude '.*' #{File.dirname(__FILE__)}/ #{ENV['server']}:#{REMOTE_CHEF_PATH}"
  end

  desc "Run chef solo on the server"
  task :cook => [:upload] do
    puts "* Running chef solo on remote server *"
    ssh_command "cd #{REMOTE_CHEF_PATH}; chef-solo -l debug -c config/solo.rb -j config/chef.json"
  end
  
end

