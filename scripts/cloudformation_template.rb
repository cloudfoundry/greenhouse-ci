require 'json'

class CloudformationTemplate
  def initialize template_json:
    @json = JSON.parse(template_json)
  end

  attr_accessor :base_url, :generate_file, :msi_file, :setup_file

  def to_json
    swap_urls template: @json, generator_url: generator_url, msi_url: msi_url, setup_url: setup_url
    JSON.pretty_generate @json
  end

  private

  def generator_url
    base_url + "/" + generate_file
  end

  def msi_url
    base_url + "/" + msi_file
  end

  def setup_url
    base_url + "/" + setup_file
  end

  def get_in(hash, keys)
    if keys.any?
      get_in(hash.fetch(keys.first), keys.drop(1))
    else
      hash
    end
  end

  def assoc_in(hash, keys, value)
    key = keys.first
    keys = keys.drop(1)
    if keys.any?
      hash[key] = assoc_in(hash[key], keys, value)
    else
      hash[key] = value
    end
    hash
  end

  def swap_urls(template:, generator_url:, msi_url:, setup_url:)
    path = ["Resources", "GardenWindowsInstance", "Metadata", "AWS::CloudFormation::Init", "config", "files"]
    files = get_in(template, path)
    files["C:\\tmp\\generate.exe"]["source"] = generator_url
    files["C:\\tmp\\diego.msi"]["source"] = msi_url
    files["C:\\tmp\\setup.ps1"]["source"] = setup_url
    assoc_in(template, path, files)
  end
end
