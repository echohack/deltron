#!/usr/bin/env ruby
require 'aws-sdk'
require 'erb'
require 'json'

stateFile = File.read('terraform.tfstate')
dashFile  = File.read('dashboard.erb')
availZone = "us-west-2"

tfState  = JSON.parse(stateFile)
testId   = tfState['modules'][0]['resources']['aws_instance.chef_automate']['primary']['attributes']['tags.TestId']
randomId = tfState['modules'][0]['resources']['random_id.automate_instance_id']['primary']['attributes']['hex']
dashBoardName = "ALT_#{testId}_#{randomId}"

renderer = ERB.new(dashFile)
dashJson = renderer.result()

cloudWatch = Aws::CloudWatch::Client.new(region: availZone)
resp = cloudWatch.put_dashboard({
  dashboard_name: dashBoardName,
  dashboard_body: dashJson,
})

