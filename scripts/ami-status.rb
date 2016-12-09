#!/usr/bin/env ruby
require 'aws-sdk'
require 'json'

class AMIStatus
  def initialize(amis:)
    @amis = amis
  end

  def ami_ready(ami)
    ENV["AWS_DEFAULT_REGION"] = ami["region"]
    image = Aws::EC2::Image.new(ami["ami_id"])
    begin
      return (image.state == "available")
    rescue
      puts "#{ami["region"]}: #{ami["ami_id"]} is not ready "
      return false
    end
  end

  def ready
    if !@amis.map { |a| ami_ready(a) }.reduce(:&)
      sleep(60)
      abort
    end
  end

end

file = File.read(File.join("amis","amis.json"))
abort "AWS_ACCESS_KEY_ID not set" unless ENV.has_key?('AWS_ACCESS_KEY_ID')
abort "AWS_SECRET_ACCESS_KEY not set" unless ENV.has_key?('AWS_SECRET_ACCESS_KEY')
AMIStatus.new(amis:JSON.parse(file)).ready
