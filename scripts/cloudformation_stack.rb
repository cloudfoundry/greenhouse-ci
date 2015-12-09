#!/usr/bin/env ruby

require_relative './ami_query'
require 'aws/cloud_formation'
require 'open-uri'
require 'uri'

class CloudformationStack
  def initialize(stack_name:, aws_credentials:)
    @cfm = AWS::CloudFormation.new(aws_credentials)
    @stack_name = stack_name
  end

  def delete_stack
    puts "deleting stack #{@stack_name}"
    stack = @cfm.stacks[@stack_name]
    stack.delete
    while stack.exists? do
      puts "waiting for stack to be destroyed"
      sleep(10)
    end
  end

  def create_stack(template, parameters)
    puts "creating stack #{@stack_name} with parameters: #{parameters}, template: #{template}"
    @cfm.stacks.create(@stack_name, template, disable_rollback: true, parameters: parameters, capabilities: ['CAPABILITY_IAM'])
  end

  def wait_for_stack
    stack = @cfm.stacks[@stack_name]
    status = stack.status
    while status != "CREATE_COMPLETE"
      raise "Create failed, #{status}" if status != "CREATE_IN_PROGRESS"
      puts "waiting for stack to complete"
      sleep(10)
      status = stack.status
    end
  end
end


