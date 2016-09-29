#
# Cookbook Name:: chef_server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


chef_ingredient 'chef-server' do
  action :install
  config <<-CONFIG
topology 'standalone'
api_fqdn '#{node['ec2']['public_hostname']}'
  CONFIG
end

ingredient_config "chef-server" do
  notifies :reconfigure, "chef_ingredient[chef-server]", :immediately
end

include_recipe 'chef_server::_manage'
#include_recipe 'chef_server::_reporting'
include_recipe 'chef_server::_push_server'
wait_for_server_startup "because"
include_recipe 'chef_server::_chef_delivery_org_setup'
include_recipe 'chef_server::_save_secrets'
