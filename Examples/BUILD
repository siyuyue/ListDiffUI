load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load(
    "@com_github_buildbuddy_io_rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "xcodeproj",
)

swift_library(
    name = "SampleAppLib",
    srcs = glob([
        "SampleApp/**/*.swift",
    ]),
    deps = [
        "//:ListDiffUI"
    ],
)

ios_application(
    name = "SampleApp",
    bundle_id = "com.siyuyue.listdiffui.sampleapp",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        "SampleApp/Info.plist",
    ],
    launch_storyboard = "SampleApp/LaunchScreen.storyboard",
    minimum_os_version = "13.0",
    deps = [
        ":SampleAppLib",
    ],
)

xcodeproj(
    name = "SampleAppProject",
    project_name = "SampleApp",
    build_mode = "bazel",
    top_level_targets = [
        top_level_target(":SampleApp", target_environments = ["simulator"]),
    ],
)
