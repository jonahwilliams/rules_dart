package(default_visibility = ["//visibility:public"])

filegroup(
    name = "dart_vm",
    srcs = select({
        "//dart:darwin_arm64": ["@dart-darwin-arm64//:dart_vm"],
        "//dart:darwin_x64": ["@dart-darwin-64//:dart_vm"],
        "//dart:linux_x64": ["@dart-linux-x64//:dart_vm"],
        "//dart:windows_x64": ["@dart-windows-x64//:dart_vm"],
    }),
)

filegroup(
    name = "flutter_tester",
    srcs = select({
        "//flutter:flutter_tester_darwin_arm64": ["@flutter-darwin-arm64-artifacts//:flutter_tester"],
        "//flutter:flutter_tester_darwin_x64": ["@flutter-darwin-64-artifacts//:flutter_tester"],
        "//flutter:flutter_tester_linux_x64": ["@flutter-linux-x64-artifacts//:flutter_tester"],
        "//flutter:flutter_tester_windows_x64": ["@flutter-windows-x64-artifacts//:flutter_tester"],
    })
)
