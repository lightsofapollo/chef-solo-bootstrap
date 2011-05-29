#
# Cookbook Name:: monit_templates
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

service "monit" do
  service_name "monit"
  restart_command "/etc/init.d/monit restart && monit monitor all"  
  action :enable
end

template "/etc/default/monit" do
  source "default_monit"
  mode 0644
  
  owner "root"
  group "root"

end

monit_config "system" do
  enable true
end

iptables_rule "monit_port" do
  enable true
end