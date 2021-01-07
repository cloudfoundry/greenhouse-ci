GOSRC = $(shell find . -name "*.go" ! -name "*test.go" ! -name "*fake*" ! -path "./integration/*")
COMMAND = out/stembuild
AUTOMATION_PATH = integration/construct/assets/StemcellAutomation.zip
AUTOMATION_PREFIX = $(shell dirname "${AUTOMATION_PATH}")
STEMCELL_VERSION = $(shell echo "$${STEMBUILD_VERSION}")
export BOSH_PSMODULES_REPO ?= ${HOME}/workspace/bosh-psmodules
LD_FLAGS = "-w -s -X github.com/cloudfoundry-incubator/stembuild/version.Version=${STEMCELL_VERSION}"

all : test build

build : out/stembuild

clean :
	rm -r version/version.go || true
	rm -r $(wildcard out/*) || true
	rm -r assets/stemcell_automation.go || true

format :
	go fmt ./...

integration : generate
	go run github.com/onsi/ginkgo/ginkgo -r -v -randomizeAllSpecs -flakeAttempts 2 integration

integration/construct : generate
	go run github.com/onsi/ginkgo/ginkgo -r -v -randomizeAllSpecs integration/construct

integration-badger : generate
	go run github.com/onsi/ginkgo/ginkgo -r -v -randomizeAllSpecs -untilItFails integration

generate: $(GOSRC) $(AUTOMATION_PATH)
	go get -u github.com/go-bindata/go-bindata/...
	go-bindata -o assets/stemcell_automation.go -pkg assets -prefix $(AUTOMATION_PREFIX) $(AUTOMATION_PATH)

out/stembuild : generate $(GOSRC)
	go build -o $(COMMAND) -ldflags $(LD_FLAGS) .

test : units

units : format generate
	@go run github.com/onsi/ginkgo/ginkgo version
	go run github.com/onsi/ginkgo/ginkgo -r -randomizeAllSpecs -randomizeSuites -skipPackage integration,iaas_cli
	@echo "\nSWEET SUITE SUCCESS"

contract :
	go run github.com/onsi/ginkgo/ginkgo -r -randomizeAllSpecs -randomizeSuites -flakeAttempts 2 iaas_cli

.PHONY : all build clean format generate
.PHONY : test units units-full integration integration-tests-full
