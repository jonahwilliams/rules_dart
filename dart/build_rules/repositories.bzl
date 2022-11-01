"""Repositories for Flutter."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def dart_build_support(is_windows):
  ext = ""
  if is_windows:
    ext = ".exe"
  return """
package(default_visibility = [ "//visibility:public" ])

filegroup(
  name = "dart_vm",
  srcs = ["dart-sdk/bin/dart{}"],
)

filegroup(
  name = "frontend_server",
  srcs = glob([
      "dart-sdk/version",
      "dart-sdk/bin/dart",
      "dart-sdk/bin/snapshots/frontend_server.dart.snapshot",
  ]),
)
""".format(ext)

ENGINE_COMMIT = "c16e2c08724c18d9275fcbcbc937af44e59e58a7"
BASE_URL = "https://storage.googleapis.com/flutter_infra_release/flutter/"
SDK_BASE_URL =  (BASE_URL + ENGINE_COMMIT + "/")

def dart_repositories():
  http_archive(
      name = "dart_linux_x86_64",
      url = SDK_BASE_URL + "dart-sdk-linux-x64.zip",
      build_file_content = dart_build_support(False),
  )

  http_archive(
      name = "dart_darwin_arm64",
      url = SDK_BASE_URL + "dart-sdk-darwin-arm64.zip",
      build_file_content = dart_build_support(False),
  )

  http_archive(
      name = "dart_darwin_x86_64",
      url = SDK_BASE_URL + "dart-sdk-darwin-x64.zip",
      build_file_content = dart_build_support(False),
  )

  http_archive(
      name = "dart_windows_x86_64",
      url = SDK_BASE_URL + "dart-sdk-windows-x64.zip",
      build_file_content = dart_build_support(True),
  )

def flutter_repositories():
  pass