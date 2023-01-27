load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load(
    "@com_github_buildbuddy_io_rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "xcodeproj",
)

swift_library(
    name = "SampleAppLib",
    module_name = "SampleAppLib",
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
    minimum_os_version = "14.0",
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

swift_library(
    name = "SampleAppLib2",
    module_name = "SampleAppLib2",
    srcs = glob([
        "SampleApp2/**/*.swift",
    ]),
    deps = [
        "//:ListDiffUI"
    ],
)

ios_application(
    name = "SampleApp2",
    bundle_id = "com.siyuyue.listdiffui.sampleapp",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        "SampleApp2/Info.plist",
    ],
    launch_storyboard = "SampleApp2/LaunchScreen.storyboard",
    minimum_os_version = "14.0",
    deps = [
        ":SampleAppLib2",
    ],
)

xcodeproj(
    name = "SampleAppProject2",
    project_name = "SampleApp2",
    build_mode = "bazel",
    top_level_targets = [
        top_level_target(":SampleApp2", target_environments = ["simulator"]),
    ],
)
