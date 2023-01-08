load("//toolchains/dot:tool.bzl", "current_dot_toolchain")

# convert toolchain to just-a-binary
#current_dot_toolchain(name = "current_dot_toolchain")

def dot(
        name,
        output = None,
        source = None,
        layout = "dot",
        imagetype = "png"):
    source_name = source or "%s.%s" % (name, "dot")
    output_name = output or "%s.%s" % (name, imagetype)

    native.genrule(
        name = "graphviz_dot_%s_%s_%s" % (name, layout, imagetype),
        srcs = [source_name],
        outs = [output_name],
        cmd = "$(DOT) -T%s $< > $@" % imagetype,
        toolchains = ["//toolchains/dot:current_dot_toolchain"],
    )
