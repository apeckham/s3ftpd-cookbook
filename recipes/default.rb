#
# Cookbook Name:: s3ftpd
# Recipe:: default
#
# Copyright 2012, apeckham
#

include_recipe "git"

git "/usr/share/s3ftpd" do
  repository "git://github.com/apeckham/s3ftpd.git"
  revision "master"
  action :sync
end

gem_package "bundler" do
  action :install
end

execute "install dependencies" do
  command "bundle install"
  cwd "/usr/share/s3ftpd"
end

service "s3ftpd" do
  provider Chef::Provider::Service::Upstart

  restart_command "stop s3ftpd; start s3ftpd"
  start_command "start s3ftpd"
  stop_command "stop s3ftpd"

  supports :restart => true, :start => true, :stop => true
end

directory "/usr/share/s3ftpd/scripts" do
  action :create
end

template "/usr/share/s3ftpd/scripts/start" do
  source "upstart.start.erb"
  mode 0755

  notifies :restart, resources(:service => "s3ftpd")
end

service "s3ftpd" do
  action [ :enable, :start ]
end