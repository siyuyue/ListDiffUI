load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

def sectionui_dependencies(is_local = False):
    new_git_repository(
        name = "ListDiff",
        remote = "https://github.com/lxcid/ListDiff.git",
        commit = "2667f8da9df3978e45841fee11d2f00934612a7f",
        shallow_since = "1538894026 +0800",
        build_file = "ListDiff.BUILD" if is_local else "@ListDiffUI//:external/ListDiff.BUILD",
    )
