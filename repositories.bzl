load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

def listdiffui_dependencies(is_local = False):
    new_git_repository(
        name = "ListDiff",
        remote = "https://github.com/lxcid/ListDiff.git",
        commit = "1390504170150f378aa1be17f92322e6d12533d8",
        shallow_since = "1593244760 +0800",
        build_file = "ListDiff.BUILD" if is_local else "@ListDiffUI//:external/ListDiff.BUILD",
    )
