#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

Dir.chdir File.join(File.dirname(__FILE__), "..", "..")

stemcell = Dir.glob("bosh-windows-stemcell/*.tgz")
FileUtils.mkdir_p("output-stemcell")
`tar xzvf #{stemcell[0]} -C output-stemcell`

stemcell_mf = YAML.load_file("output-stemcell/stemcell.MF")
final_version = File.read('version/number').match(/\d+\.\d+/)[0]
stemcell_mf["version"] = final_version
File.open("output-stemcell/stemcell.MF", "w") {|f| f.write stemcell_mf.to_yaml }

stemcell_name = File.basename(stemcell[0]).gsub(/\d+\.\d+\.\d+-rc\.\d+/, final_version)
Dir.chdir "output-stemcell" do
  `tar czvf ../final-stemcell/#{stemcell_name} *`
end
