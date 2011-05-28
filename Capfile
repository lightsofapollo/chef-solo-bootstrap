require 'yaml'
REMOTE_CHEF_PATH = "/etc/chef" # Where to find upstream cookbooks

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set(:rvm_bin_path, '/usr/local/rvm/bin/')
default_run_options[:pty] = true

unless(self.respond_to?(:run_locally))
  def run_locally(cmd)
    logger.trace "executing locally: #{cmd.inspect}" if logger
    output_on_stdout = nil
    elapsed = Benchmark.realtime do
      output_on_stdout = `#{cmd}`
    end
    if $?.to_i > 0 # $? is command exit code (posix style)
      raise Capistrano::LocalArgumentError, "Command #{cmd} returned status code #{$?}"
    end
    logger.trace "command finished in #{(elapsed * 1000).round}ms" if logger
    output_on_stdout
  end
end

def sudo_env(cmd)
  run "#{sudo} -i #{cmd}"
end


def server_config_env
  if !ENV["server"]
    puts "No server given checking for defaults..."

    yaml_file = File.open(File.dirname(__FILE__) + '/server.yml', 'r')

    yaml = YAML.load(yaml_file)
    yaml_file.close

    
    yaml = yaml['server'] || {}
    
    if(yaml['user'] && yaml['host'])
      ENV['server'] = yaml['user'] + '@' + yaml['host']
    else
      puts "When using the default you must create a server.yml see server.yml.tpl"
      exit 1
    end
  end  
end

server_config_env

role :target, ENV['server']

namespace :chef do
  
  desc "Test your cookbooks and config files for syntax errors"
  task :check do
    Dir[ File.join(File.dirname(__FILE__), "**", "*.rb") ].each do |recipe|
      sh %{ruby -c #{recipe}} do |ok, res|
        raise "Syntax error in #{recipe}" if not ok
      end
    end

  end

  desc "Installs required gems (assumes ruby and required libraries for chef)" 
  task :install do
    sudo_env "gem install ohai chef --no-ri --no-rdoc"
  end
  
  
  desc "Upload the latest copy of your cookbooks to remote server"
  task :upload do
    puts "* Upload your cookbooks *"
    run_locally "rsync -rlP --delete --exclude '.*' --exclude 'server.ym*' #{File.dirname(__FILE__)}/ #{ENV['server']}:#{REMOTE_CHEF_PATH}"
  end

  desc "Run chef solo on the server"
  task :cook do
    upload
    puts "* Running chef solo on remote server *"
    sudo_env "chef-solo -l debug -c #{REMOTE_CHEF_PATH}/config/solo.rb -j #{REMOTE_CHEF_PATH}/config/chef.json"
  end
  
end

