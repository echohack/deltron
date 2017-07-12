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

#these steps minify the json bypassing entityTooLarge errors
dashHash = JSON.parse(renderer.result())
dashJson = JSON.generate(dashHash)

cloudWatch = Aws::CloudWatch::Client.new(region: availZone)
resp = cloudWatch.put_dashboard({
  dashboard_name: dashBoardName,
  dashboard_body: dashJson,
})
puts "https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards:name=#{dashBoardName}"
