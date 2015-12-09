require 'json'

class CloudformationTemplate
  def initialize(template_json:)
    @json = JSON.parse(template_json)
  end

  def ami=(value)
    @json["Parameters"]["ZZZAMI"]["Default"] = value
  end

  def generator_url=(value)
    @json["Parameters"]["ZZZGenerateUrl"]["Default"] = value
  end

  def diego_windows_msi_url=(value)
    @json["Parameters"]["ZZZDiegoWindowsMsiUrl"]["Default"] = value
  end

  def garden_windows_msi_url=(value)
    @json["Parameters"]["ZZZGardenWindowsMsiUrl"]["Default"] = value
  end

  def setup_ps1_url=(value)
    @json["Parameters"]["ZZZSetupPs1Url"]["Default"] = value
  end

  def hakim_url=(value)
    @json["Parameters"]["ZZZHakimUrl"]["Default"] = value
  end

  def to_json
    JSON.pretty_generate(@json)
  end

end
