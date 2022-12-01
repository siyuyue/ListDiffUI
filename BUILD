load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ListDiffUI",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "@ListDiff//:ListDiff",
    ],
    visibility = ["//visibility:public"],
)
