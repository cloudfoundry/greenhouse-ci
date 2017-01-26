#!/usr/bin/env ruby

require 'aws-sdk'

class VMs
  def initialize(name)
    @name= name
    @regions = ["us-east-1","us-east-2","us-west-1","us-west-2",
    "ca-central-1","ap-south-1","ap-northeast-1","ap-northeast-2",
    "ap-southeast-1","ap-southeast-2","eu-central-1","eu-west-1",
    "eu-west-2","sa-east-1"]
  end

  def delete
    @regions.each do |region|
      ec2 = Aws::EC2::Client.new(region: region)
      reservations = ec2.describe_instances(filters:[{ name: 'tag:Name', values:[@name]}])
      instances = reservations.map { |r| r.reservations.map(&:instances).flatten.map { |x| x.instance_id } }.flatten
      if instances.any? then
        puts "Deleting #{instances.to_s} in region #{region}"
        ec2.terminate_instances({
          dry_run: false,
          instance_ids: instances
        })
      end
    end
  end

end

abort "AWS_ACCESS_KEY_ID not set" unless ENV.has_key?('AWS_ACCESS_KEY_ID')
abort "AWS_SECRET_ACCESS_KEY not set" unless ENV.has_key?('AWS_SECRET_ACCESS_KEY')
abort "VM_NAME not set" unless ENV.has_key?('VM_NAME')
VMs.new(ENV["VM_NAME"]).delete
