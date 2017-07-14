require_relative '../../../stemcell-builder/lib/stemcell/builder'

# Concourse inputs
version_dir = '../version'
output_directory = '../bosh-windows-stemcell/packer-output' # packer-output must not exist before packer is run!

version = File.read(File.join(version_dir, 'number')).chomp

input_dir = Stemcell::Builder::validate_env('INPUT_DIR') # Concourse worker configured ahead of time
vhd_path = File.join(input_dir, Dir.entries("#{input_dir}").detect { |e| File.extname(e) == ".vhd" })
vmx_path = File.join(input_dir, Dir.entries("#{input_dir}").detect { |e| File.extname(e) == ".vmx" })

output_vmdk_path = File.join(output_directory, 'output.vmdk')
signature_path = File.join(output_directory, 'signature')
diff_path = File.join(output_directory, "patchfile-#{version}")

vsphere = Stemcell::Builder::VSphere.new(
  mem_size: '4096',
  num_vcpus: '4',
  source_path: vmx_path,
  agent_commit: "",
  administrator_password: Stemcell::Builder::validate_env('ADMINISTRATOR_PASSWORD'),
  product_key: Stemcell::Builder::validate_env('PRODUCT_KEY'),
  owner: Stemcell::Builder::validate_env('OWNER'),
  organization: Stemcell::Builder::validate_env('ORGANIZATION'),
  os: Stemcell::Builder::validate_env('OS_VERSION'),
  output_directory: output_directory,
  packer_vars: {},
  version: version,
  skip_windows_update: true,
  new_password: Stemcell::Builder::validate_env('ADMINISTRATOR_PASSWORD')
)

vsphere.run_packer

signature_command = "gordiff signature #{vhd_path} #{signature_path}"
puts "generating signature: #{signature_command}"
`#{signature_command}`

diff_command = "gordiff delta #{signature_path} #{output_vmdk_path} #{diff_path}"
puts "generating diff: #{diff_command}"
`#{diff_command}`
