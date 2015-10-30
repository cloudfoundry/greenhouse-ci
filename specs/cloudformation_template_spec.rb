require_relative '../scripts/cloudformation_template'

describe CloudformationTemplate do
  describe '#to_json' do
    it 'returns the template with the interpolated values' do
      template_json = <<-TEMPLATE_JSON
{
  "Parameters": {
    "ZZZGenerateUrl": {},
    "ZZZDiegoWindowsMsiUrl": {},
    "ZZZGardenWindowsMsiUrl": {},
    "ZZZSetupPs1Url": {},
    "ZZZHakimUrl": {}
  }
}
      TEMPLATE_JSON

      template = CloudformationTemplate.new(template_json: template_json)
      template.generator_url = 'http://foo.com/generate.exe'
      template.diego_windows_msi_url = 'http://bar.com/dwm.msi'
      template.garden_windows_msi_url = 'http://baz.com/gwm.msi'
      template.setup_url = 'setup.ps1'
      template.hakim_url = 'hakim.exe'

      expect(template.to_json).to eq (<<-EXPECTED_JSON).strip
{
  "Parameters": {
    "ZZZGenerateUrl": {
      "Default": "http://foo.com/generate.exe"
    },
    "ZZZDiegoWindowsMsiUrl": {
      "Default": "http://bar.com/dwm.msi"
    },
    "ZZZGardenWindowsMsiUrl": {
      "Default": "http://baz.com/gwm.msi"
    },
    "ZZZSetupPs1Url": {
      "Default": "setup.ps1"
    },
    "ZZZHakimUrl": {
      "Default": "hakim.exe"
    }
  }
}
      EXPECTED_JSON
    end
  end
end
