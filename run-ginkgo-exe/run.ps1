$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

ginkgo.exe -p -r -race -cover -keepGoing -randomizeSuites $env:TEST_PATH
Exit $LastExitCode
