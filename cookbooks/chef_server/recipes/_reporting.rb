
chef_ingredient 'reporting' do
  notifies :reconfigure, 'chef_ingredient[reporting]'
  accept_license true
end
