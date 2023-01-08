def graphviz(name, src):
    native.genrule(
        name = name,
        srcs = [src],
        outs = [name + ".png"],
        tools = ["@graphviz//:nix/bin/dot"],
        cmd = "$(location @graphviz//:nix/bin/dot) $(location {src}) -Tpng > $@".format(src = src),
    )
