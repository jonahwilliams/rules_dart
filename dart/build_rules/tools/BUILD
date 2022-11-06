package(default_visibility = ["//visibility:public"])

filegroup(
    name = "dart2js_helper",
    srcs = select({
        "//dart:darwin_arm64": ["dart2js_helper.sh"],
        "//dart:darwin_x64": ["dart2js_helper.sh"],
    }),
)
