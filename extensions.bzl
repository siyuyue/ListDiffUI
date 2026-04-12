load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def _non_bazel_deps_impl(ctx):
    git_repository(
        name = "list_diff",
        remote = "https://github.com/lxcid/ListDiff.git",
        commit = "1390504170150f378aa1be17f92322e6d12533d8",
        # Inject your custom BUILD file here
        build_file = "external/list_diff.BUILD",
    )

non_bazel_deps = module_extension(implementation = _non_bazel_deps_impl)
