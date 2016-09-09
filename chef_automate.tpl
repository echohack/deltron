# download and install Chef Automate
sudo curl -o /home/ec2-user/delivery-0.5.204-1.el7.x86_64.rpm -L https://packages.chef.io/stable/el/7/delivery-0.5.204-1.el7.x86_64.rpm
sudo rpm -Uvh -i /home/ec2-user/delivery-0.5.204-1.el7.x86_64.rpm

sudo delivery-ctl setup --license ~/chef_automate.license --key ${chef_automate_user_key} --server-url https://${chef_server_public_dns}/organizations/${chef_automate_org} --fqdn ${chef_automate_public_dns} --configure
delivery-ctl create-enterprise ${enterprise_name} --ssh-pub-key-file=/etc/delivery/builder_key.pub

sudo curl -o /home/ec2-user/chefdk-0.17.17-1.el7.x86_64.rpm -L https://packages.chef.io/stable/el/7/chefdk-0.17.17-1.el7.x86_64.rpm

# delivery-ctl install-build-node --fqdn $BUILD_NODE_FQDN --username $SSH_USERNAME --password $SSH_PASSWORD --installer $CHEF_DK_PACKAGE_PATH --ssh-identity-file $SSH_IDENTITY_FILE --port $SSH_PORT --overwrite-registration