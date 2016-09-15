
chef_ingredient 'manage' do
  notifies :reconfigure, 'chef_ingredient[manage]'
  accept_license true
end
