def _current_dot_toolchain_impl(ctx):
    """based on the current_py_toolchain, this provides a vars[] loaded with the binary/binaries in
    the current dor toolchain (future: graphviz?).  Unfortunately, the system binary needs to be
    converted to a Files() and that's not working here yet.

    Current state is that it provides the associative array of paths in the vars[] returned as a TemplateVariableInfo() but doesn't map a dependency on the system binary.  It completely ignores the "label" for now, unfortunately.
    """

    toolchain = ctx.toolchains[ctx.attr._toolchain]

    direct = []
    transitive = []
    vars = {}

    if toolchain.dot.label:
        vars["DOT"] = toolchain.dot.label.path
        #direct.append(toolchain.dot.label)
        #print("adding direct dependency on label {}".format(toolchain.dot.label))

    if toolchain.dot.path:
        vars["DOT"] = toolchain.dot.path
        #f = ctx.actions.declare_file(toolchain.dot.path)
        #direct.append(f)
        #print("adding direct dependency on path {} ({})".format(toolchain.dot.path, f.path))

    files = depset(direct, transitive = transitive)  # both empty until the Files ref works

    return [
        toolchain,
        platform_common.TemplateVariableInfo(vars),
        DefaultInfo(
            runfiles = ctx.runfiles(transitive_files = files),  # empty until the Files ref works
            files = files,  # empty until the Files ref works
        ),
    ]

current_dot_toolchain = rule(
    doc = """
    This rule exists to convert a dot_toolchain_type into a path of a dot binary so that it can be used
    in a basic dependency such as a genrule()
    """,
    implementation = _current_dot_toolchain_impl,
    attrs = {
        "_toolchain": attr.string(providers = str(Label("//toolchains/dot:dot_toolchain_type"))),
    },
    toolchains = [
        str(Label("@@//toolchains/dot:dot_toolchain_type")),
    ],
)
