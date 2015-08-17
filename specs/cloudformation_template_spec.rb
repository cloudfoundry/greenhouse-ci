require_relative '../scripts/cloudformation_template'

describe CloudformationTemplate do
  describe '#to_json' do
    it 'returns the template with the interpolated values' do
      template_json = <<-TEMPLATE_JSON
{
  "Resources": {
    "GardenWindowsInstance": {
      "Type": "AWS::EC2::Instance",
      "Metadata": {
        "AWS::CloudFormation::Init": {
          "config": {
            "files": {
              "C:\\\\tmp\\\\generate.exe": {
                "source": "https://github.com/cloudfoundry-incubator/diego-windows-msi/releases/download/v0.494/generate.exe"
              },
              "C:\\\\tmp\\\\diego.msi": {
                "source": "https://github.com/cloudfoundry-incubator/diego-windows-msi/releases/download/v0.494/DiegoWindowsMSI.msi"
              },
              "C:\\\\tmp\\\\setup.ps1": {
                "source": "https://github.com/cloudfoundry-incubator/diego-windows-msi/releases/download/v0.494/setup.ps1"
              }
            }
          }
        }
      }
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
  "Resources": {
    "GardenWindowsInstance": {
      "Type": "AWS::EC2::Instance",
      "Metadata": {
        "AWS::CloudFormation::Init": {
          "config": {
            "files": {
              "C:\\\\tmp\\\\generate.exe": {
                "source": "http://foo.com/dir/generate.exe"
              },
              "C:\\\\tmp\\\\diego.msi": {
                "source": "http://foo.com/dir/DiegoWindowsMSI.msi"
              },
              "C:\\\\tmp\\\\setup.ps1": {
                "source": "http://foo.com/dir/setup.ps1"
              }
            }
          }
        }
      }
    }
  }
}
      EXPECTED_JSON
    end
  end
end
