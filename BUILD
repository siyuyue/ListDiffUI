load("@rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ListDiffUI",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "@list_diff//:ListDiff",
    ],
    visibility = ["//visibility:public"],
)
