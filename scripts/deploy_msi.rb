#!/usr/bin/env ruby

### NEW ###
# destroy old cloudformation stack
# substitute generator & msi URLs in cloudformation.json
# run cloudformation template on aws
# wait for it to finish / succeed? -- boosh

require_relative './cloudformation_template'
require 'aws/cloud_formation'

def delete_stack(name)
  puts "deleting stack #{name}"
  stack = $cfm.stacks[name]
  stack.delete
  while stack.exists? do
    puts "waiting for stack to be destroyed"
    sleep(10)
  end
end

def create_stack(name, template, parameters)
  puts "creating stack #{name}"
  $cfm.stacks.create(name, template, parameters: parameters)
end

def wait_for_stack(name)
  stack = $cfm.stacks[name]
  status = stack.status
  while status != "CREATE_COMPLETE"
    raise "Create failed, #{status}" if status != "CREATE_IN_PROGRESS"
    puts "waiting for stack to complete"
    sleep(10)
    status = stack.status
  end
end

$cfm = AWS::CloudFormation.new(access_key_id: ENV["AWS_ACCESS_KEY_ID"],
                               secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
generator_url = ENV["GENERATOR_URL"] || File.read("install-script-generator/url")
msi_url = ENV["MSI_URL"] || File.read("msi-file/url")
setup_url = ENV["SETUP_URL"] || msi_url.gsub("DiegoWindowsMSI", "setup").gsub(".msi", ".ps1")

delete_stack(ENV["STACKNAME"])
template = swap_urls(template: JSON.parse(File.read("diego-windows-msi/cloudformation.json")),
                     generator_url: generator_url,
                     msi_url: msi_url,
                     setup_url: setup_url)
# binding.pry
create_stack(ENV["STACKNAME"], template, {
  BoshHost: ENV.fetch("BOSH_HOST"),
  BoshPassword: ENV.fetch("BOSH_PASSWORD"),
  BoshUserName: ENV.fetch("BOSH_USER"),
  CellName: ENV["CELL_NAME"],
  ContainerizerPassword: ENV.fetch("CONTAINERIZER_PASSWORD"),
  GardenWindowsSubnet: ENV.fetch("SUBNET"),
  SecurityGroup: ENV.fetch("SECURITY_GROUP")
})
wait_for_stack(ENV["STACKNAME"])




######################
#################
#
# fails when run with this script, passes when run through the Cloudformation UI with the same args
# not sure what is going wrong
# #########################
#
#
#
