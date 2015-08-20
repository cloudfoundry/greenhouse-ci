#!/usr/bin/env ruby

require_relative './cloudformation_template'
require 'aws/cloud_formation'
require 'uri'

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

delete_stack(ENV["STACKNAME"])

template = CloudformationTemplate.new(template_json: File.read("diego-windows-msi/cloudformation.json"))
template.base_url = 'https://diego-windows-msi.s3.amazonaws.com/output'
template.generate_file = File.basename(URI(File.read("greenhouse-install-script-generator/url")).path)
template.msi_file = File.basename(URI(File.read("msi-file/url")).path)
template.setup_file = template.msi_file.gsub("DiegoWindowsMSI", "setup").gsub(".msi", ".ps1")

create_stack(ENV["STACKNAME"], template.to_json, {
  BoshHost: ENV.fetch("BOSH_HOST"),
  BoshPassword: ENV.fetch("BOSH_PASSWORD"),
  BoshUserName: ENV.fetch("BOSH_USER"),
  CellName: ENV["CELL_NAME"],
  ContainerizerPassword: ENV.fetch("CONTAINERIZER_PASSWORD"),
  GardenWindowsSubnet: ENV.fetch("SUBNET"),
  SecurityGroup: ENV.fetch("SECURITY_GROUP")
})

wait_for_stack(ENV["STACKNAME"])
