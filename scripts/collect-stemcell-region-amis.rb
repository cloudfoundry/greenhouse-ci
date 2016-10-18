#!/usr/bin/env ruby

require 'json'

regions = []
Dir.glob('windows-ami-*').each do |ami_dir|
	region_info = {}
	region_info["name"] = ami_dir.sub("windows-ami-", "")
	region_info["base_ami"] = File.read(File.join(ami_dir, 'version')).chomp

	region_var_name = region_info["name"].upcase.gsub("-", "_")
	region_info["vpc_id"] = ENV.fetch("VPC_ID_#{region_var_name}")
	region_info["subnet_id"] = ENV.fetch("SUBNET_ID_#{region_var_name}")

	regions.push(region_info)
end

File.open(File.join("stemcell-regions", "regions.json"),"w") do |f|
  f.write(regions.to_json)
end
