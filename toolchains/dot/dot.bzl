"""toolchain to provide a dot binary."""

# This is modeled after the rpmbuild logic, but currenty not building a replacement.  I want to leave this as an option if I amend the upstream graphviz.
#
# likely need to expand to a graphviz toolchain with a dot et al component.

DotInfo = provider(
    doc = """platform-dependent dot artifact, either pre-built or build on-demand.""",
    fields = {
        "name": "The name of the toolchain",
        "valid": "Is this toolchain valid and usable?",
        "label": "The path to a target I will (TBA) build using external_build per https://graphviz.org/doc/build.html",
        "path": "The path to a pre-built dot",
        "version": "The version string of dot",
    },
)

def _dot_toolchain_impl(ctx):
    if ctx.attr.label and ctx.attr.path:
        fail("dot_toolchain must not specify both label and path.")
    valid = bool(ctx.attr.label) or bool(ctx.attr.path)
    toolchain_info = platform_common.ToolchainInfo(
        dot = DotInfo(
            name = str(ctx.label),
            valid = valid,
            label = ctx.attr.label,
            path = ctx.attr.path,
            version = ctx.attr.version,
        ),
    )
    return [toolchain_info]

dot_toolchain = rule(
    implementation = _dot_toolchain_impl,
    attrs = {
        "label": attr.label(
            doc = "A valid label of a target to build or a prebuilt binary. Mutually exclusive with path.",
            cfg = "exec",
            executable = True,
            allow_files = True,
        ),
        "path": attr.string(
            doc = "The path to the dot executable. Mutually exclusive with label.",
        ),
        "version": attr.string(
            doc = "The version string of the dot executable. This should be manually set.",
        ),
    },
)

# Expose the presence of an dot in the resolved toolchain as a flag.
def _is_dot_available_impl(ctx):
    toolchain = ctx.toolchains["@com_github_chickenandpork_diagrams//toolchains/dot:dot_toolchain_type"].dot
    return [config_common.FeatureFlagInfo(
        value = ("1" if toolchain.valid else "0"),
    )]

is_dot_available = rule(
    implementation = _is_dot_available_impl,
    attrs = {},
    toolchains = ["@com_github_chickenandpork_diagrams//toolchains/dot:dot_toolchain_type"],
)

def dot_register_toolchains():
    native.register_toolchains("@com_github_chickenandpork_diagrams//toolchains/dot:dot_missing_toolchain")
