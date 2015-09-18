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

  def swap_urls(template:, generator_url:, msi_url:, setup_url:)
    files = template.fetch("Parameters")
    files["ZZZGenerateUrl"]["Default"] = generator_url
    files["ZZZDiegoMsiUrl"]["Default"] = msi_url
    files["ZZZSetupPs1Url"]["Default"] = setup_url
  end
end
