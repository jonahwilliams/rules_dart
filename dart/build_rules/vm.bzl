# Copyright 2016 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Dart rules targeting the Dart VM."""


load(":internal.bzl", "collect_files", "layout_action", "make_dart_context", "package_config_action")


def _dart_vm_binary_impl(ctx):
  """Implements the dart_vm_binary() rule."""
  dart_ctx = make_dart_context(ctx.label,
                               srcs=ctx.files.srcs,
                               data=ctx.files.data,
                               deps=ctx.attr.deps)

  out_snapshot = ctx.actions.declare_file(ctx.label.name + ".exe")
  vm_aot_action(
    ctx=ctx,
    dart_ctx=dart_ctx,
    output=out_snapshot,
    vm_flags=ctx.attr.vm_flags,
    script_file=ctx.file.script_file,
    script_args=ctx.attr.script_args,
  )

  return [DefaultInfo(
    executable=out_snapshot,
  )]


_dart_vm_binary_attrs = {
    "script_file": attr.label(allow_single_file=True, mandatory=True),
    "script_args": attr.string_list(),
    "vm_flags": attr.string_list(),
    "srcs": attr.label_list(allow_files=True, mandatory=True),
    "data": attr.label_list(allow_files=True),
    "deps": attr.label_list(providers=["dart"]),
    "snapshot": attr.bool(default=True),
    "_dart_vm": attr.label(
        allow_single_file=True,
        executable=True,
        cfg="exec",
        default=Label("//dart/build_rules/ext:dart_vm"),
    ),
}


dart_vm_binary = rule(
    implementation=_dart_vm_binary_impl,
    attrs=_dart_vm_binary_attrs,
    executable=True,
)


def vm_snapshot_action(ctx, dart_ctx, output, vm_flags, script_file, script_args):
  """Emits a Dart VM snapshot."""
  build_dir = ctx.label.name + ".build/"

  # Emit package spec.
  package_spec_path = ctx.label.package + "/" + ctx.label.name + ".packages"
  package_spec = ctx.actions.declare_file(build_dir + package_spec_path)
  package_config_action(
      ctx=ctx,
      output=package_spec,
      dart_ctx=dart_ctx,
  )

  # Build a flattened directory of dart2js inputs, including inputs from the
  # src tree, genfiles, and bin.
  all_srcs, _ = collect_files(dart_ctx)
  build_dir_files = layout_action(
      ctx=ctx,
      srcs=all_srcs,
      output_dir=build_dir,
  )
  out_script = build_dir_files[script_file.short_path]

  # TODO(cbracken) assert --snapshot not in flags
  # TODO(cbracken) assert --packages not in flags
  arguments = [
      "--packages=%s" % package_spec.path,
      "--snapshot=%s" % output.path,
  ]
  arguments += vm_flags
  arguments.append(out_script.path)
  arguments += script_args
  ctx.actions.run(
      inputs=build_dir_files.values() + [package_spec],
      outputs=[output],
      executable=ctx.executable._dart_vm,
      arguments=arguments,
      progress_message="Building Dart VM snapshot %s" % ctx,
      mnemonic="DartVMSnapshot",
  )

def _dart_vm_snapshot_impl(ctx):
  """Implements the dart_vm_snapshot build rule."""
  dart_ctx = make_dart_context(ctx.label,
                               srcs=ctx.files.srcs,
                               data=ctx.files.data,
                               deps=ctx.attr.deps)
  vm_snapshot_action(
      ctx=ctx,
      dart_ctx=dart_ctx,
      output=ctx.outputs.snapshot,
      vm_flags=ctx.attr.vm_flags,
      script_file=ctx.file.script_file,
      script_args=ctx.attr.script_args,
  )
  return struct()


def vm_aot_action(ctx, dart_ctx, output, vm_flags, script_file, script_args):
  """Emits a Dart AOT executable."""
  build_dir = ctx.label.name + ".build/"

  # Emit package spec.
  package_spec_path = ctx.label.package + "/" + ctx.label.name + ".packages"
  package_spec = ctx.actions.declare_file(build_dir + package_spec_path)
  package_config_action(
      ctx=ctx,
      output=package_spec,
      dart_ctx=dart_ctx,
  )

  # Build a flattened directory of compiler inputs, including inputs from the
  # src tree, genfiles, and bin.
  all_srcs, _ = collect_files(dart_ctx)
  build_dir_files = layout_action(
      ctx=ctx,
      srcs=all_srcs,
      output_dir=build_dir,
  )
  out_script = build_dir_files[script_file.short_path]

  arguments = [
      "compile",
      "exe",
      "--packages=%s" % package_spec.path,
      "--output=%s" % output.path,
  ]
  arguments += vm_flags
  arguments.append(out_script.path)
  arguments += script_args
  ctx.actions.run(
      inputs=build_dir_files.values() + [package_spec],
      outputs=[output],
      executable=ctx.executable._dart_vm,
      arguments=arguments,
      progress_message="Building Dart AOT executable %s" % ctx,
      mnemonic="DartVMExecutable",
  )

def _dart_vm_aot_impl(ctx):
  """Implements the dart_vm_aot_action build rule."""
  dart_ctx = make_dart_context(ctx.label,
                               srcs=ctx.files.srcs,
                               data=ctx.files.data,
                               deps=ctx.attr.deps)
  vm_aot_action(
      ctx=ctx,
      dart_ctx=dart_ctx,
      output=ctx.outputs.snapshot,
      vm_flags=ctx.attr.vm_flags,
      script_file=ctx.file.script_file,
      script_args=ctx.attr.script_args,
  )
  return struct()

_dart_vm_aot_binary_attrs = {
    "script_file": attr.label(allow_single_file=True, mandatory=True),
    "script_args": attr.string_list(),
    "vm_flags": attr.string_list(),
    "srcs": attr.label_list(allow_files=True, mandatory=True),
    "data": attr.label_list(allow_files=True),
    "deps": attr.label_list(providers=["dart"]),
    "_dart_vm": attr.label(
        allow_single_file=True,
        executable=True,
        cfg="exec",
        default=Label("//dart/build_rules/ext:dart_vm"),
    ),
}

dart_vm_snapshot = rule(
    implementation=_dart_vm_snapshot_impl,
    attrs=_dart_vm_binary_attrs,
    outputs={"snapshot": "%{name}.snapshot"},
)

dart_vm_executable = rule(
    implementation=_dart_vm_aot_impl,
    attrs=_dart_vm_binary_attrs,
    outputs={"executable": "%{name}.exe"},
)

def _dart_vm_test_impl(ctx):
  """Implements the dart_vm_test() rule."""
  dart_ctx = make_dart_context(ctx.label,
                               srcs=ctx.files.srcs,
                               data=ctx.files.data,
                               deps=ctx.attr.deps)

  # Emit package spec.
  package_spec = ctx.actions.declare_file(ctx.label.name + ".packages")
  package_config_action(
      ctx=ctx,
      dart_ctx=dart_ctx,
      output=package_spec,
  )

  dart_args = []
  dart_args += ctx.attr.vm_flags
  dart_args.append("--packages={}".format(package_spec.short_path))
  dart_args.append(ctx.file.script_file.short_path)
  dart_args += ctx.attr.script_args

  # Compute runfiles.
  all_srcs, all_data = collect_files(dart_ctx)
  runfiles_files = all_data + [
      ctx.executable._dart_vm,
      ctx.outputs.executable,
  ]
  runfiles_files += all_srcs
  runfiles_files.append(package_spec)
  runfiles = ctx.runfiles(
      files=list(runfiles_files),
  )

  ctx.actions.run(
    mnemonic = "DartVM",
    executable = ctx.executable._dart_vm.short_path,
    arguments = dart_args,
    inputs = runfiles_files,
    outputs = [ctx.outputs.executable],
  )

  return struct(
      runfiles=runfiles,
      instrumented_files=struct(
          source_attributes=["srcs"],
          dependency_attributes=["deps"],
      ),
  )

_dart_vm_test_attrs = {
    "script_file": attr.label(allow_single_file=True, mandatory=True),
    "script_args": attr.string_list(),
    "vm_flags": attr.string_list(),
    "srcs": attr.label_list(allow_files=True, mandatory=True),
    "data": attr.label_list(allow_files=True),
    "deps": attr.label_list(providers=["dart"]),
    "_dart_vm": attr.label(
        allow_single_file=True,
        executable=True,
        cfg="host",
        default=Label("//dart/build_rules/ext:dart_vm")),
}


dart_vm_test = rule(
    implementation=_dart_vm_test_impl,
    attrs=_dart_vm_test_attrs,
    executable=True,
    test=True,
)
