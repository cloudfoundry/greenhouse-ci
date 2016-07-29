#!/usr/bin/env ruby

require_relative './cloudformation_stack'
require 'aws/cloud_formation'
require 'open-uri'
require 'uri'

credentials = {
  access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
  secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
}

stack         = CloudformationStack.new(stack_name: ENV.fetch('STACKNAME'), aws_credentials: credentials)

stack.delete_stack
