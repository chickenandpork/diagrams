"""Repository rule to autoconfigure a toolchain using the system dot."""

def _write_build(rctx, path, version):
    if not path:
        path = ""
    rctx.template(
        "BUILD",
        Label("//toolchains/dot:BUILD.tpl"),
        substitutions = {
            "{GENERATOR}": "@@//toolchains/dot/dot_configure.bzl%find_system_dot",
            "{RPMBUILD_PATH}": str(path),
            "{RPMBUILD_VERSION}": version,
        },
        executable = False,
    )

def _find_system_dot_impl(rctx):
    dot_path = rctx.which("dot")
    if True:   # rctx.attr.verbose:
        if dot_path:
            print("Found dot at '%s'" % dot_path)  # buildifier: disable=print
        else:
            print("No system dot found.")  # buildifier: disable=print
    version = "unknown"
    if dot_path:
        fail("dot found")
        res = rctx.execute([dot_path, "-V"])
        if res.return_code == 0:
            # expect stdout like: dot - graphviz version 7.0.6 (20230106.0513)
            parts = res.stdout.strip().split(" ")
            if parts[0] == "dot" and parts[3] == "version":
                version = parts[4]
    else:
        fail("no dot found")
    _write_build(rctx = rctx, path = dot_path, version = version)

_find_system_dot = repository_rule(
    implementation = _find_system_dot_impl,
    doc = """Create a repository that defines a (graphviz) dot toolchain based on the dot discovered in the system.""",
    local = True,
    environ = ["PATH"],
    attrs = {
        "verbose": attr.bool(
            doc = "If true, print status messages.",
        ),
    },
)

def find_system_dot(virtual_dependency_name, verbose = False):
    _find_system_dot(name = virtual_dependency_name, verbose = verbose)
    native.register_toolchains(
        "@%s//:dot_auto_toolchain" % virtual_dependency_name,
        "@@//toolchains/dot:dot_missing_toolchain",
    )
