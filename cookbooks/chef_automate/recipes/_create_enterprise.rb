delivery_databag = data_bag_item('automate', 'automate')

file '/etc/delivery/builder_key' do
  content delivery_databag['builder_pub']
  owner 'root'
  group 'root'
  mode 0400
  action :create
end

file '/etc/delivery/builder_key.pub' do
  content delivery_databag['builder_pem']
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

execute 'create delivery enterprise' do
  command 'delivery-ctl create-enterprise delivery --ssh-pub-key-file=/etc/delivery/builder_key.pub > /home/ec2-user/admin.creds'
  not_if 'delivery-ctl list-enterprises --ssh-pub-key-file=/etc/delivery/builder_key.pub | grep -w delivery'
end

file '/home/ec2-user/admin.creds' do
  owner 'ec2-user'
end
