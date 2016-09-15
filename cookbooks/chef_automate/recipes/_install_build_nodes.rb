remote_file '/tmp/chefdk.el7.x86_64.rpm' do
  source "http://omnitruck.chef.io/stable/chefdk/download?p=el&pv=7&m=x86_64&v=latest"
end

node['chef_automate']['build_nodes'].each do |build_node|
  execute "Install build node #{build_node}" do
    command "delivery-ctl install-build-node --fqdn #{build_node} --username chef --installer /tmp/chefdk.el7.x86_64.rpm --password chef --overwrite-registration"
    action :run
  end
end
