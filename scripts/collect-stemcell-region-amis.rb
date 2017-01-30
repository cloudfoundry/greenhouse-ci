#!/usr/bin/env ruby

require 'json'

region_names = [
  "us-east-1",
  "us-east-2",
  "us-west-1",
  "us-west-2",
  "ca-central-1",
  "ap-south-1",
  "ap-northeast-2",
  "ap-southeast-1",
  "ap-southeast-2",
  "ap-northeast-1",
  "eu-central-1",
  "eu-west-1",
  "eu-west-2",
  "sa-east-1"
]
region_infos = []
region_names.each do |region_name|
  region_info = {}
  region_info['name'] = region_name

  amis = JSON.parse(`aws ec2 describe-images \
           --owners amazon \
          --filters "Name=name,Values=Windows_Server-2012-R2_RTM-English-64Bit-Base*" "Name=state,Values=available"`)
  base_ami = (amis['Images'].sort { |a,b| b['CreationDate'] <=> a['CreationDate']  }).map { |x| x['ImageId'] }.first
  region_info['base_ami'] = base_ami

  vpcs = JSON.parse(`aws ec2 describe-vpcs \
              --region #{region_name}`)
  vpc_id = vpcs['Vpcs'].first["VpcId"]
  if vpc_id.nil? || vpc_id.empty?
    raise "Error: no vpc id found for region '#{region_name}'"
  end
  region_info['vpc_id'] = vpc_id

  subnets = JSON.parse(`aws ec2 describe-subnets \
                --region #{region_name} \
                --filters "Name=vpc-id,Values=#{vpc_id}"`)
  subnet_id = subnets["Subnets"].first["SubnetId"]
  if subnet_id.nil? || subnet_id.empty?
    raise "Error: no subnet id found for vpc '#{vpc_id}' in region '#{region_name}'"
  end
  region_info['subnet_id'] = subnet_id

  sg_name = 'packer-aws-stemcell'
  sgs = JSON.parse(`aws ec2  describe-security-groups \
              --region #{region_name} \
              --group-names #{sg_name} \
              --filters "Name=vpc-id,Values=#{vpc_id}"`)
  sg_id = sgs["SecurityGroups"].first["GroupId"]
  if sg_id.nil? || sg_id.empty?
    raise "Error: no security group found with name '#{sg_name}' for vpc '#{vpc_id}' in region '#{region_name}'"
  end
  region_info['security_group'] = sg_id

  region_infos.push(region_info)
end

if region_infos.size != region_names.size
  raise 'Error: unable to generate valid region information'
end

puts JSON.pretty_generate(region_infos)

File.open(File.join('stemcell-regions', 'regions.json'), 'w') do |f|
  f.write(region_infos.to_json)
end
