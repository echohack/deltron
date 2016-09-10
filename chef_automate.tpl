delivery_fqdn "${chef_automate_public_dns}"
delivery['chef_username']    = "chef_automate"
delivery['chef_private_key'] = "/etc/delivery/delivery.pem"
delivery['chef_server']      = "https://${chef_server_public_dns}/organizations/delivery"
delivery['default_search']   = "((recipes:delivery_build OR tags:delivery-build-node OR recipes:delivery_build\\\\\\\\:\\\\\\\\:default) AND chef_environment:_default)"
insights['enable'] = true
