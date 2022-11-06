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
SDK_BASE_URL = (BASE_URL + ENGINE_COMMIT + "/")

HOST_PLATFORMS = [
    "darwin-x64",
    "darwin-arm64",
    "windows-x64",
    "linux-x64",
    "linux-arm64",
]

FLUTTER_ARTIFACTS = [
    "gen_snapshot",
]

# Downloads the Dart SDK per supported HOST_PLATFORM
def dart_repositories():
    for host_platform in HOST_PLATFORMS:
        http_archive(
            name = "dart-" + host_platform,
            url = SDK_BASE_URL + "dart-sdk-" + host_platform + ".zip",
            build_file_content = dart_build_support(host_platform == "windows-x64"),
        )

def flutter_repo_content(flutter_artifact):
    return """
package(default_visibility = [ "//visibility:public" ])

filegroup(
  name = "{}",
  srcs = ["{}"],
)
""".format(flutter_artifact, flutter_artifact)

def flutter_host_artifacts_content(is_windows):
    ext = ""
    if (is_windows):
        ext = ".exe"

    return """
package(default_visibility = [ "//visibility:public" ])

filegroup(
  name = "debug_snapshots",
  srcs = ["vm_isolate_snapshot.bin", "isolate_snapshot.bin"],
)

filegroup(
  name = "icu_data",
  srcs = ["icudtl.dat"]
)

filegroup(
  name = "impellerc",
  srcs = ["impellerc{}"],
)

filegroup(
  name = "flutter_tester",
  srcs = ["flutter_tester{}"]
)
""".format(ext, ext)

# Download all Flutter SDK artifacts per host platform
def flutter_repositories():
    for host_platform in HOST_PLATFORMS:
        is_windows = host_platform == "windows-x64"
        for flutter_artifact in FLUTTER_ARTIFACTS:
            http_archive(
                name = "flutter-" + host_platform + "-" + flutter_artifact,
                url = SDK_BASE_URL + host_platform + "/" + flutter_artifact,
                build_file_content = flutter_repo_content(flutter_artifact),
            )

        # Generic host artifacts
        http_archive(
            name = "flutter-" + host_platform + "-artifacts",
            url = SDK_BASE_URL + host_platform + "/artifacts.zip",
            build_file_content = flutter_host_artifacts_content(is_windows)
        )
