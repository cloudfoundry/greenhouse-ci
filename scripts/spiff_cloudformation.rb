#!/usr/bin/env ruby

require_relative './cloudformation_template'

credentials = {
  access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
  secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
}

template_file_path              = Dir::glob("diego-windows-cloudformation-template-file/*.json.template").first
template                        = CloudformationTemplate.new(template_json: File.read(template_file_path))
template.generator_url          = File.read("greenhouse-install-script-generator-file/url")
template.diego_windows_msi_url  = File.read("diego-windows-msi-file/url")
template.garden_windows_msi_url = File.read("garden-windows-msi-file/url")
template.setup_ps1_url          = File.read("garden-windows-setup-file/url")
template.hakim_url              = File.read("hakim/url")

ami_query                       = AMIQuery.new(aws_credentials: credentials)
template.ami                    = ami_query.latest_ami

File.write('generated-cloudformation-template-file/cloudformation.json', template.to_json)
