## Greenhouse CI

Set of concourse tasks and dockerfiles for greenhouse

## Stembuild

Fixed the vmx file we are using to refer to the base vmdk (the one created from Microsoft's vhd using VBoxManage). We were taking the vmx from stembuild's template vmx but that didn't have an ethernet card so packer was failing to connect to the cloned vm. The vmx to use is located in bosh-windows-stemcell-builder/create-vsphere-vmdk/stemcell.vmx
