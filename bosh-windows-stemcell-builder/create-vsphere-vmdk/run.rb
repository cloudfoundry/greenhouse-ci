require_relative '../../../stemcell-builder/lib/stemcell/builder'
require_relative '../../../stemcell-builder/lib/s3'

# Concourse inputs
version_dir = '../version'
output_directory = '../bosh-windows-stemcell/packer-output' # packer-output must not exist before packer is run!

version = File.read(File.join(version_dir, 'number')).chomp

signature_path = File.join(output_directory, 'signature')
diff_path = File.join(output_directory, "patchfile-#{version}")

aws_access_key_id = Stemcell::Builder::validate_env('AWS_ACCESS_KEY_ID')
aws_secret_access_key = Stemcell::Builder::validate_env('AWS_SECRET_ACCESS_KEY')
aws_region = Stemcell::Builder::validate_env('AWS_REGION')

image_bucket = Stemcell::Builder::validate_env('VHD_VMDK_BUCKET')
# output_bucket = Stemcell::Builder::validate_env('DIFF_OUTPUT_BUCKET')
cache_dir = Stemcell::Builder::validate_env('CACHE_DIR')

s3_client = S3::Client.new(
  aws_access_key_id: aws_access_key_id,
  aws_secret_access_key: aws_secret_access_key,
  aws_region: aws_region)

last_file = s3_client.list(image_bucket).sort.last
image_basename = File.basename(last_file, File.extname(last_file))

vmdk_filename = image_basename + '.vmdk'
vhd_filename = image_basename + '.vhd'
vmdk_location = File.join(cache_dir, vmdk_filename)
vhd_location = File.join(cache_dir, vhd_filename)

if !File.exist?(vmdk_location)
  s3_client.get(image_bucket, vmdk_filename, vmdk_location)
end
if !File.exist?(vhd_location)
  s3_client.get(image_bucket, vhd_filename, vhd_location)
end

vmx_template_txt = File.read("../ci/bosh-windows-stemcell-builder/create-vsphere-vmdk/old-base-vmx.vmx")
new_vmx_txt = vmx_template_txt.gsub("INIT_VMDK",vmdk_location)
File.write("config.vmx", new_vmx_txt)
vmx_path = File.absolute_path("config.vmx").gsub("/", "\\")

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

signature_command = "gordiff signature #{vhd_location} #{signature_path}"
puts "generating signature: #{signature_command}"
`#{signature_command}`

diff_command = "gordiff delta #{signature_path} #{output_vmdk_path} #{diff_path}"
puts "generating diff: #{diff_command}"
`#{diff_command}`
