#
# Cookbook Name:: main
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if platform?("redhat","centos","debian","ubuntu")
  include_recipe "iptables"
  
  iptables_rule "ssh_port"
  iptables_rule "mysql_port"
  
  monit_config "deamon"
  monit_config "apache"
  monit_config "memcached"
  monit_config "mysql"
  
end