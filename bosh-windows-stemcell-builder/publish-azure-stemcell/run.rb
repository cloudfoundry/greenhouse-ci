#!/usr/bin/env ruby

require_relative '../../../stemcell-builder/lib/exec_command'

exec_command("rake publish:azure")
