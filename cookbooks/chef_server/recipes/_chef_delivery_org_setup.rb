#
# Recipe to be executed on the Chef server to setup a Delivery user and Organization
#

chef_server_user 'delivery' do
  firstname 'Delivery'
  lastname 'User'
  email 'delivery@services.com'
  password 'delivery'
  private_key_path '/tmp/delivery.pem'
  action :create
end

chef_server_org 'delivery' do
  org_long_name 'Chef Delivery Organization'
  org_private_key_path '/tmp/delivery-validator.pem'
  action :create
end

chef_server_org 'delivery' do
  admins %w{ delivery }
  action :add_admin
end
