#!/usr/bin/env ruby

require_relative './cloudformation_template'
require_relative './cloudformation_stack'
require 'aws/cloud_formation'
require 'open-uri'
require 'uri'

credentials = {
  access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
  secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
}

template_file = Dir::glob("diego-windows-cloudformation-template-file/*.json").first
template      = CloudformationTemplate.new(template_json: File.read(template_file))
stack         = CloudformationStack.new(stack_name: ENV.fetch('STACKNAME'), aws_credentials: credentials)

stack.delete_stack
stack.create_stack(template.to_json, {
  BoshHost:              ENV.fetch('BOSH_HOST'),
  BoshPassword:          ENV.fetch('BOSH_PASSWORD'),
  BoshUserName:          ENV.fetch('BOSH_USER'),
  CellName:              ENV.fetch('CELL_NAME'),
  ContainerizerPassword: ENV.fetch('CONTAINERIZER_PASSWORD'),
  SecurityGroup:         ENV.fetch('SECURITY_GROUP'),
  SubnetCIDR:            ENV.fetch('SUBNET_CIDR'),
  NATInstance:           ENV.fetch('NAT_INSTANCE_ID'),
  VPCID:                 ENV.fetch('VPC_ID'),
  DesiredCapacity:       ENV.fetch('DESIRED_CAPACITY'),
  KeyPair:               ENV.fetch('KEY_PAIR'),
})

stack.wait_for_stack
