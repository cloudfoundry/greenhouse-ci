require_relative '../../../stemcell-builder/lib/stemcell/builder'

version_dir = Stemcell::Builder::validate_env_dir('VERSION_DIR')
version = File.read(File.join(version_dir, 'number')).chomp

vsphere = Stemcell::Builder::VSphere.new(
  mem_size: ENV.fetch('MEM_SIZE', '4096'),
  num_vcpus: ENV.fetch('NUM_VCPUS', '8'),
  source_path: Stemcell::Builder::validate_env('VMX_PATH'),
  agent_commit: "",
  administrator_password: Stemcell::Builder::validate_env('ADMINISTRATOR_PASSWORD'),
  product_key: Stemcell::Builder::validate_env('PRODUCT_KEY'),
  owner: Stemcell::Builder::validate_env('OWNER'),
  organization: Stemcell::Builder::validate_env('ORGANIZATION'),
  os: Stemcell::Builder::validate_env('OS_VERSION'),
  output_directory: Stemcell::Builder::validate_env('OUTPUT_DIR'),
  packer_vars: {},
  version: version
)

vsphere.run_packer
