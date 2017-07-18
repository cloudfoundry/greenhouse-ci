require_relative '../../../stemcell-builder/lib/stemcell/builder'

# Concourse inputs
version_dir = '../version'
output_directory = '../bosh-windows-stemcell/packer-output' # packer-output must not exist before packer is run!

version = File.read(File.join(version_dir, 'number')).chomp

vhd_path = Dir["../base-vhds/*.vhd"].first
vmdk_path = Dir['../primed-vmdks/*.vmdk'].first
vmx_path = "../ci/bosh-windows-stemcell-builder/create-vsphere-vmdk/old-base-vmx.vmx"

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
output_vmdk_path = File.join(output_directory, Dir.entries("#{output_directory}").detect { |e| File.extname(e) == ".vmdk" })

signature_command = "gordiff signature #{vhd_path} #{signature_path}"
puts "generating signature: #{signature_command}"
`#{signature_command}`

diff_command = "gordiff delta #{signature_path} #{output_vmdk_path} #{diff_path}"
puts "generating diff: #{diff_command}"
`#{diff_command}`
