#!/usr/bin/env ruby

require 'octokit'
require 'time'
require 'open-uri'
require 'tempfile'
require_relative './cloudformation_template'
require_relative './ami_query'

def token
  ENV['GITHUB_TOKEN'] or raise "Environment variable #{var} isn't set"
end

def generate_file
  Dir::glob('./greenhouse-install-script-generator-file/generate*.exe').first
end

def diego_windows_msi_file
  Dir::glob('./diego-windows-msi-file/DiegoWindows*.msi').first
end

def hakim_file
  Dir::glob('./hakim/*.exe').first
end

def garden_windows_msi_file
  Dir::glob('./garden-windows-msi-file/GardenWindows*.msi').first
end

def garden_windows_setup_file
  Dir::glob('./garden-windows-setup-file/*.ps1').first
end

def github
  @github ||= Octokit::Client.new access_token: token
end

def create_github_release(repo, sha, version, body)
  puts "Creating release #{version} with sha #{sha}"
  github.create_tag repo,
                    version,
                    "Release #{version}",
                    sha,
                    "commit",
                    "greenhouse-ci ", # tagger name isn't being used by the api
                    "pivotal-netgarden-eng@pivotal.io", # tagger email isn't being used by the api
                    Time.now.utc.iso8601

  github.create_release(repo,
                        version,
                        name: version,
                        body: body,
                        draft: true)
end

def diego_windows_sha
  msi_sha diego_windows_msi_file
end

def garden_windows_sha
  msi_sha garden_windows_msi_file
end

def diego_release_sha
  dw_sha = diego_windows_sha
  Dir.chdir "diego-windows-release" do
    # e.g. output from `git submodule status` on a vanilla clone (NOTE shas will have '-' if submodule update wasn't run)
    # -755de0e75052301d38a21cf24b486434c9f4d934 diego-release
    # -e6b27981c2bcdbcb1c9052412078aa472b8181d3 greenhouse-install-script-generator
    # -b4e6600cd2b2f8737b25c36259cc582b74e247f8 loggregator
    submodule_shas = `git checkout #{dw_sha} && git submodule status`
    sha = submodule_shas.split("\n").grep(/diego-release/).first
    sha = sha.split.first # -755de0e75052301d38a21cf24b486434c9f4d934
    sha[1..-1] # 755de0e75052301d38a21cf24b486434c9f4d934
  end
end

def msi_sha msi_file
  raise "invalid filename #{msi_file}" unless msi_file =~ /.*-(\d+\.\d+)-(.*)\.msi/
  $2
end

def upload_release_assets(filepath, release, filename=nil)
  filename ||= File.basename filepath
  github.upload_asset release[:url],
                      filepath,
                      content_type: "application/octet-stream",
                      name: filename
end

def get_release_resource(repo, release)
  github.releases(repo).select { |r| r.tag_name == release}.first
end

def create_cloudformation_release
  ami_query = AMIQuery.new(aws_credentials: {
    access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
    secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY")
  })

  template_json_file = Dir::glob("diego-windows-cloudformation-template-file/*.json.template").first
  template_json = File.read(template_json_file)
  template = CloudformationTemplate.new(template_json: template_json)
  diego_base_url = "https://github.com/cloudfoundry/diego-windows-release/releases/download/#{diego_version}"
  garden_base_url = "https://github.com/cloudfoundry/garden-windows-release/releases/download/#{garden_version}"
  template.ami = ami_query.latest_ami
  template.generator_url = "#{diego_base_url}/generate.exe"
  template.diego_windows_msi_url = "#{diego_base_url}/DiegoWindows.msi"
  template.garden_windows_msi_url = "#{garden_base_url}/GardenWindows.msi"
  template.setup_ps1_url = "#{garden_base_url}/setup.ps1"
  template.hakim_url = "#{diego_base_url}/hakim.exe"

  Tempfile.new('cloudformation-release.json').tap do |tempfile|
    tempfile.write(template.to_json)
    tempfile.close
  end
end

def diego_repo
  "cloudfoundry/diego-windows-release"
end

def garden_repo
  "cloudfoundry/garden-windows-release"
end

def get_version dir
  version = File.read("./#{dir}/version").chomp
  "v#{version}"
end

def diego_version
  get_version "diego-windows-msi-file"
end

def garden_version
  get_version "garden-windows-msi-file"
end

def diego_release_body
  <<HERE
Built using cloudfoundry-incubator/diego-release@#{diego_release_sha}; Compatible with garden-windows #{garden_version}
HERE
end

def garden_release_body
  <<HERE
Compatible with diego-windows #{diego_version} & cloudfoundry-incubator/diego-release@#{diego_release_sha}
HERE
end

def garden_release_resources
  {
    garden_windows_msi_file => "GardenWindows.msi",
    garden_windows_setup_file => "setup.ps1"
  }
end

def diego_release_resources
  {
    diego_windows_msi_file => "DiegoWindows.msi",
    generate_file => "generate.exe",
    create_cloudformation_release.path => "cloudformation.json",
    hakim_file => "hakim.exe"
  }
end

def release name
  repo = send "#{name}_repo"
  sha = send "#{name}_windows_sha"
  version = send "#{name}_version"
  release_resource = get_release_resource repo, version
  body = send "#{name}_release_body"

  if release_resource then
    puts "Update Existing Resource"
    body = release_resource.body + "\n\n-------------\n" + body
    github.update_release(release_resource.url, { body: body })
  else
    puts "Creating github release"
    release = create_github_release repo, sha, version, body
    puts "Created github release"

    send("#{name}_release_resources").each do |resource, resource_name|
    puts "Uploading #{resource} to github release"
    upload_release_assets resource, release, resource_name
    puts "Uploaded #{resource} to github release"
    end

    github.update_release(release.url, { draft: false })
  end
end

release "diego"
release "garden"
