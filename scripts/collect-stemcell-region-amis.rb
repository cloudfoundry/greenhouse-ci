#!/usr/bin/env ruby

require 'json'

regions = []
Dir.glob('windows-ami-*').each do |ami_dir|
	region_info = {}
  region_name = ami_dir.sub('windows-ami-', '')
	region_info['name'] = region_name
	region_info['base_ami'] = File.read(File.join(ami_dir, 'version')).chomp

  vpc_id = `aws ec2 describe-vpcs \
              --region #{region_name} | \
              jq -r .Vpcs[0].VpcId`.chomp
  if vpc_id.nil? || vpc_id.empty?
    raise "Error: no vpc id found for region '#{region_name}'"
  end
	region_info['vpc_id'] = vpc_id

  subnet_id = `aws ec2 describe-subnets \
                --region #{region_name} \
                --filters "Name=vpc-id,Values=#{vpc_id}" | \
                jq -r .Subnets[0].SubnetId`.chomp
  if subnet_id.nil? || subnet_id.empty?
    raise "Error: no subnet id found for vpc '#{vpc_id}' in region '#{region_name}'"
  end
	region_info['subnet_id'] = subnet_id

  sg_name = 'packer-aws-stemcell'
  sg_id = `aws ec2  describe-security-groups \
              --region #{region_name} \
              --group-names #{sg_name} \
              --filters "Name=vpc-id,Values=#{vpc_id}" | \
              jq -r .SecurityGroups[0].GroupId`.chomp
	if sg_id.nil? || sg_id.empty?
    raise "Error: no security group found with name '#{sg_name}' for vpc '#{vpc_id}' in region '#{region_name}'"
  end
  region_info['security_group'] = sg_id

	regions.push(region_info)
end

if regions.empty?
  raise 'Error: no regional ami resources provided'
end

File.open(File.join('stemcell-regions', 'regions.json'), 'w') do |f|
  f.write(regions.to_json)
end
