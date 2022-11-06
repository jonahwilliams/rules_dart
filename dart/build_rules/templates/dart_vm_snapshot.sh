#!/bin/bash
set -e

dart="$RUNFILES/%workspace%/%dart_vm%"
script_file="$RUNFILES/%workspace%/%script_file%"
"$dart" %vm_flags% "$script_file" %script_args% "$@"
