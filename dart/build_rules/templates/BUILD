dadpackage(default_visibility = ["//visibility:public"])

filegroup(
    name = "dart_vm_snapshot",
    srcs = select({
        "//dart:darwin_arm64": ["dart_vm_snapshot.sh"],
        "//dart:darwin_x64": ["dart_vm_snapshot.sh"],
        "//dart:linux_x64": ["dart_vm_snapshot.sh"],
        "//dart:linux_arm64": ["dart_vm_snapshot.sh"],
        "//dart:windows_x64": ["dart_vm_snapshot.bat"],
    }),
)

filegroup(
    name = "dart_vm_test_template",
    srcs = select({
        "//dart:coverage_config": [":dart_vm_test_coverage"],
        "//conditions:default": [":dart_vm_test"],
    }),
)

filegroup(
    name = "dart_vm_test",
    srcs = select({
        "//dart:darwin_arm64": ["dart_vm_test.sh"],
        "//dart:darwin_x64": ["dart_vm_test.sh"],
    }),
)

filegroup(
    name = "dart_vm_test_coverage",
    srcs = select({
        "//dart:darwin_arm64": ["dart_vm_test_coverage.sh"],
        "//dart:darwin_x64": ["dart_vm_test_coverage.sh"],
    }),
)
