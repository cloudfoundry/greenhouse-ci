#!/usr/bin/env ruby

require_relative './cloudformation_template'

template_file_path              = Dir::glob("diego-windows-cloudformation-template-file/*.json.template").first
template                        = CloudformationTemplate.new(template_json: File.read(template_file_path))
template.generator_url          = File.read("greenhouse-install-script-generator-file/url")
template.diego_windows_msi_url  = File.read("diego-windows-msi-file/url")
template.garden_windows_msi_url = File.read("garden-windows-msi-file/url")
template.setup_ps1_url              = File.read("garden-windows-setup-file/url")
template.hakim_url              = File.read("hakim/url")

File.write(template_file, template.to_json)
