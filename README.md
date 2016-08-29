## Greenhouse CI

### Setup [BOSH Windows Stemcell Builder Pipeline](./bosh-windows-consumer.yml)

Concourse pipeline for creating BOSH Windows Stemcells.

#### Prerequisites

[Stemcell builder](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-builder), please refer to the [README](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-builder/blob/master/README.md) for additional requirements.

#### Install Concourse

Follow the instructions at [Concourse](http://concourse.ci/installing.html).  This pipeline has been tested on [v1.6.0](http://concourse.ci/downloads.html#v160) using [Concourse-Lite](http://concourse.ci/vagrant.html) and a [BOSH Deployed Cluster](http://concourse.ci/clusters-with-bosh.html).

#### Configure Pipeline

[Example parameters](./examples/consumer-vars.yml).
