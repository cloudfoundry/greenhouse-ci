require 'json'

class CloudformationTemplate
  def initialize template_json:
    @json = JSON.parse(template_json)
  end

  attr_accessor :generator_url, :diego_windows_msi_url, :garden_windows_msi_url, :setup_url

  def to_json
    JSON.pretty_generate swap_urls
  end

  private

  def swap_urls
    @json.dup.tap do |json|
      files = json.fetch("Parameters")
      files["ZZZGenerateUrl"]["Default"] = generator_url
      files["ZZZDiegoWindowsMsiUrl"]["Default"] = diego_windows_msi_url
      files["ZZZGardenWindowsMsiUrl"]["Default"] = garden_windows_msi_url
      files["ZZZSetupPs1Url"]["Default"] = setup_url
    end
  end
end
