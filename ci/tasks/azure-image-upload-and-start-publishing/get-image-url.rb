#!/usr/bin/env ruby

require_relative '../../../stemcell-builder/lib/stemcell/publisher/azure.rb'
require_relative '../../../stemcell-builder/lib/stemcell/manifest.rb'

# require_relative '../../../bosh-windows-stemcell-builder/lib/stemcell/publisher/azure.rb'

container_root = File.expand_path('../../../..', __FILE__)
version = File.read(File.join(container_root, 'version', 'number')).chomp
# puts "in here"
# puts container_root
# puts version
# container_name = ENV['AZURE_CONTAINER_NAME']
# puts container_name
# exit
puts "in here 1"

# Get the container path for sas create
uri_filename = "bosh-stemcell-*-azure-vhd-uri.txt"
puts "in here 2"
image_url = File.read(Dir.glob(File.join(container_root, 'azure-base-vhd-uri', uri_filename)).first).chomp
puts "in here 3"
container_path = (image_url.match %r{(Microsoft\.Compute/Images/.*vhd)})[0]
puts "in here 4"

publisher = Stemcell::Publisher::Azure.new(
  version: Stemcell::Manifest::Azure.format_version(version),
  sku: ENV['SKU'],
  azure_storage_account: ENV['AZURE_PUBLISHED_STORAGE_ACCOUNT'],
  azure_storage_access_key: ENV['AZURE_PUBLISHED_STORAGE_ACCESS_KEY'],
  azure_tenant_id: ENV['AZURE_TENANT_ID'],
  azure_client_id: ENV['AZURE_CLIENT_ID'],
  azure_client_secret: ENV['AZURE_CLIENT_SECRET'],
  container_name: ENV['AZURE_CONTAINER_NAME'],
  container_path: container_path
)

puts "in here 5"

vhd_url = publisher.vhd_url
puts "in here 6"

# return value to calling script
puts vhd_url

