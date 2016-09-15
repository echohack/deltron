
chef_ingredient 'push-jobs-server' do
  notifies :reconfigure, 'chef_ingredient[push-jobs-server]'
end
