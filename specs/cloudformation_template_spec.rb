require_relative '../scripts/cloudformation_template'

describe CloudformationTemplate do
  describe '#to_json' do
    it 'returns the template with the interpolated values' do
      template_json = <<-TEMPLATE_JSON
{
  "Parameters": {
    "ZZZGenerateUrl": {
      "Description": "URL of generate.exe",
      "Type": "String",
      "Default": ""
    },
    "ZZZDiegoMsiUrl": {
      "Description": "URL of the diego.msi to install",
      "Type": "String",
      "Default": ""
    },
    "ZZZSetupPs1Url": {
      "Description": "URL of the setup.ps1 to run",
      "Type": "String",
      "Default": ""
    }
  }
}
      TEMPLATE_JSON

      template = CloudformationTemplate.new(template_json: template_json)
      template.base_url = 'http://foo.com/dir'
      template.generate_file = 'generate.exe'
      template.msi_file = 'DiegoWindowsMSI.msi'
      template.setup_file = 'setup.ps1'

      expect(template.to_json).to eq (<<-EXPECTED_JSON).strip
{
  "Parameters": {
    "ZZZGenerateUrl": {
      "Description": "URL of generate.exe",
      "Type": "String",
      "Default": "http://foo.com/dir/generate.exe"
    },
    "ZZZDiegoMsiUrl": {
      "Description": "URL of the diego.msi to install",
      "Type": "String",
      "Default": "http://foo.com/dir/DiegoWindowsMSI.msi"
    },
    "ZZZSetupPs1Url": {
      "Description": "URL of the setup.ps1 to run",
      "Type": "String",
      "Default": "http://foo.com/dir/setup.ps1"
    }
  }
}
      EXPECTED_JSON
    end
  end
end
