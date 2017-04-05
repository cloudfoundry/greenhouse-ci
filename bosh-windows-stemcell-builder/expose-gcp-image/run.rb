#!/usr/bin/env ruby

require 'net/http'
require 'rubygems/package'
require 'uri'
require 'json'
require 'yaml'
require 'tempfile'

def read_from_tgz(path, filename)
  contents = ''
  tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(path))
  tar_extract.rewind
  tar_extract.each do |entry|
    if entry.full_name.include?(filename)
      contents = entry.read
    end
  end
  tar_extract.close
  contents
end

root_dir = File.expand_path('../../../../', __FILE__)
pattern = File.join(root_dir,'bosh-windows-stemcell', '*.tgz')
stemcell = Dir.glob(pattern)[0]
if stemcell.nil?
  abort "Unable to find stemcell: #{pattern}"
end
stemcell_mf = read_from_tgz(stemcell,'stemcell.MF')
manifest = YAML.load(stemcell_mf)
image_name = File.basename(manifest['cloud_properties']['image_url'])


account_json = JSON.parse(ENV['ACCOUNT_JSON'])
account_email = account_json['client_email']
project_id = account_json['project_id']

Tempfile.create('bwats-') do |f|
  f.write(ENV['ACCOUNT_JSON'])
  f.close
  `gcloud auth activate-service-account --quiet #{account_email} --key-file #{f.path}`
  uri = URI.parse("https://www.googleapis.com/compute/alpha/projects/#{project_id}/global/images/#{image_name}/setIamPolicy")
  token = `gcloud auth print-access-token`
  header = {'Content-Type': 'application/json', 'Authorization': "Bearer #{token}"}
  data = {
    bindings: [
      {
        role: 'roles/compute.imageUser',
        members: [ 'allAuthenticatedUsers' ]
      }
    ]
  }
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = data.to_json

  response = http.request(request)
  puts "#{response.message}: #{response.body}"
  exit (response.kind_of? Net::HTTPSuccess)

end

