current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                \"delivery-validator\"
client_key               \"#{current_dir}/delivery-validator.pem\"
chef_server_url          \"https://${chef_server}/organizations/delivery\"
knife[:aws_credential_file] = File.join(ENV['HOME'], \"/.aws/credentials\")
