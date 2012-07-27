apt_package "make" do
  action :install
end

apt_package "libc6-dev" do
  action :install
end

begin
  apt_package "vsftpd" do
    action :install
  end

  service "vsftpd" do
    supports restart: true
    action [:enable, :start]
  end

  cookbook_file "/etc/vsftpd.conf" do
    source "vsftpd.conf"
    mode 0644
    notifies :restart, resources(service: "vsftpd")
  end
end

begin
  cookbook_file "/etc/shells" do
    source "shells"
    mode 0644
  end

  chef_gem "ruby-shadow"

  user "upload" do
    password node[:s3ftpd][:password]
    home "/home/upload"
    shell "/bin/false"
  end

  directory "/home/upload" do
    user "upload"
    group "upload"
    mode 0555
  end

  directory "/home/upload/incoming" do
    user "upload"
    group "upload"
    mode 0755
  end
end

begin
  apt_package "s3cmd" do
    action :install
  end

  template "/usr/share/s3cfg" do
    source "s3cfg.erb"
    mode 0644
  end
end

begin
  apt_package "inotify-tools" do
    action :install
  end

  service "inotify-s3" do
    provider Chef::Provider::Service::Upstart

    restart_command "stop inotify-s3 && start inotify-s3"
    start_command "start inotify-s3"
    stop_command "stop inotify-s3"

    supports :restart => true, :start => true, :stop => true
  end

  template "/etc/init/inotify-s3.conf" do
    source "upstart.conf.erb"
    mode 0644

    notifies :restart, resources(:service => "inotify-s3")
  end
end