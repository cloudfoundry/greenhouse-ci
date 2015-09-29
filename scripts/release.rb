#!/usr/bin/env ruby

require 'octokit'
require 'time'
require 'open-uri'
require 'tempfile'
require_relative './cloudformation_template'

def token
  ENV['GITHUB_TOKEN'] or raise "Environment variable #{var} isn't set"
end

def generate_file
  Dir::glob('./greenhouse-install-script-generator-file/generate*.exe').first
end

def diego_windows_msi_file
  Dir::glob('./diego-windows-msi-file/DiegoWindows*.msi').first
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

def create_github_tag(repo, sha, version)
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
                        body: cf_diego_release_text)
end

def diego_windows_sha
  msi_sha diego_windows_msi_file
end

def diego_release_sha
  Dir.chdir "diego-windows-release" do
    # e.g. output from `git submodule status` on a vanilla clone
    # -755de0e75052301d38a21cf24b486434c9f4d934 diego-release
    # -e6b27981c2bcdbcb1c9052412078aa472b8181d3 greenhouse-install-script-generator
    # -b4e6600cd2b2f8737b25c36259cc582b74e247f8 loggregator
    submodule_shas = `git checkout #{diego_windows_sha} && git submodule status`
    sha = submodule_shas.split("\n").grep(/diego-release/).first
    sha = sha.split.first # -755de0e75052301d38a21cf24b486434c9f4d934
    sha[1..-1] # 755de0e75052301d38a21cf24b486434c9f4d934
  end
end

def msi_sha msi_file
  raise "invalid filename #{msi_file}" unless msi_file =~ /.*-(\d+\.\d+)-(.*)\.msi/
  $2
end

def cf_diego_release_text
  release_body = <<-BODY
cloudfoundry-incubator/diego-release@#{diego_sha}
BODY
  release_body
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

def create_cloudformation_release version
  template_json_file = Dir::glob("diego-windows-cloudformation-template-file/*.json.template").first
  template_json = File.read(template_json_file)
  template = CloudformationTemplate.new(template_json: template_json)
  base_url = "https://github.com/cloudfoundry-incubator/diego-windows-release/releases/download/#{version}"
  template.generator_url = "#{base_url}/generate.exe"
  template.diego_windows_msi_url = "#{base_url}/DiegoWindows.msi"
  template.garden_windows_msi_url = "#{base_url}/GardenWindows.msi"
  template.setup_url = "#{base_url}/setup.ps1"

  Tempfile.new('cloudformation-release.json').tap do |tempfile|
    tempfile.write(template.to_json)
    tempfile.close
  end
end

def diego_repo
  "cloudfoundry-incubator/diego-windows-release"
end

def garden_repo
  "cloudfoundry-incubator/garden-windows-release"
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

def release_diego_windows
  repo = diego_repo
  msi_file = diego_windows_msi_file
  sha = diego_windows_sha
  version = diego_version
  release_resource = get_release_resource repo, version

  if release_resource then
    puts "Update Existing Resource"
    body = release_resource.body
    body += "\n\n-------------\n" + <<HERE
Compatible with garden-windows #{garden_version}
HERE
    github.update_release(release_resource.url, { body: body })
  else
    puts "Creating github release"
    res = create_github_tag repo, sha, version
    puts "Created github release"

    puts "Uploading msi to github release"
    upload_release_assets msi_file, res, "DiegoWindowsMSI.msi"
    puts "Uploaded msi to github release"

    puts "Uploading generate to github release"
    upload_release_assets generate_file, res, "generate.exe"
    puts "Uploaded generate to github release"

    puts "Uploading cloudformation script to github release"
    tmp_cloudformation_file = create_cloudformation_release version
    upload_release_assets tmp_cloudformation_file.path, res, "cloudformation.json"
    puts "Uploaded cloudformation script to github release"
  end
end

def release_garden_window
  repo = garden_repo
  msi_file = garden_windows_msi_file
  sha = msi_sha msi_file
  version = garden_version
  release_resource = get_release_resource repo, version

  if release_resource then
    puts "Update Existing Resource"
    body = release_resource.body
    body += "\n\n-------------\n" + <<HERE
Compatible with diego-windows #{diego_version} & diego-release #{diego_release_sha}
HERE
    github.update_release(release_resource.url, { body: body })
  else
    puts "Creating github release"
    res = create_github_tag repo, sha, version
    puts "Created github release"

    puts "Uploading msi to github release"
    upload_release_assets msi_file, res, "GardenWindowsMSI.msi"
    puts "Uploaded msi to github release"

    puts "Uploading setup script to github release"
    upload_release_assets garden_windows_setup_file, res, "setup.ps1"
    puts "Uploaded setup script to github release"
  end
end

release_garden_window
release_diego_windows
