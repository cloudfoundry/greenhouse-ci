#!/usr/bin/env ruby
require 'aws-sdk'
require 'json'

class AMIStatus
  def initialize(aws_credentials:,amis:)
    @aws_credentials= aws_credentials
    @amis = amis
  end

  def ami_ready(ami)
    ec2 = Aws::EC2::Client.new(region: ami["region"],credentials: @aws_credentials)
    begin
      image_results = ec2.describe_images(image_ids: [ ami["ami_id"] ])
      return (image_results.images[0].state == "available")
    rescue
      puts "#{ami["region"]}: #{ami["ami_id"]} is not ready "
      return false
    end
  end

  def ready
    if !@amis.map { |a| ami_ready(a) }.reduce(:&)
      abort
    end
  end

end

sleep(60)
file = File.read(File.join("amis","amis.json"))
cred = Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY_ID'), ENV.fetch('AWS_SECRET_ACCESS_KEY'))
AMIStatus.new(aws_credentials: cred, amis:JSON.parse(file)).ready
