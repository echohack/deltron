#!/bin/sh

sudo mkdir /etc/opscode

cat <<EOF > ~/chef-server.rb
topology "standalone"
EOF

sudo mv ~/chef-server.rb /etc/opscode/chef-server.rb

# install chef server and follow the redirect from packages.chef.io
sudo curl -o /home/ec2-user/chef-server-core-12.8.0-1.el7.x86_64.rpm -L https://packages.chef.io/stable/el/7/chef-server-core-12.8.0-1.el7.x86_64.rpm
sudo rpm -Uvh -i /home/ec2-user/chef-server-core-12.8.0-1.el7.x86_64.rpm
sudo chef-server-ctl reconfigure --accept-license
sudo chef-server-ctl user-create chef_automate Chef Automate automate@example.com abc123 --filename /home/ec2-user/chef_automate.pem
sudo chef-server-ctl org-create delivery 'delivery' --association_user chef_automate --filename /home/ec2-user/delivery-validator.pem
sudo chef-server-ctl install opscode-reporting
sudo opscode-reporting-ctl reconfigure --accept-license
sudo chef-server-ctl install chef-manage
sudo chef-manage-ctl reconfigure --accept-license
sudo chef-server-ctl install opscode-push-jobs-server
sudo opscode-push-jobs-server-ctl reconfigure
sudo chef-server-ctl reconfigure
