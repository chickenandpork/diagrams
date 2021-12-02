def dot(
        name,
	output = None,
	source = None,
	layout = "dot",
	imagetype = "png",
):

    source_name = source or "%s.%s" % (name, "dot")
    output_name = output or "%s.%s" % (name, imagetype)

    native.genrule(
	name = "graphviz_dot_%s_%s_%s" % (name, layout, imagetype),
        srcs = [ source_name ],
	outs = [ output_name ],
        cmd = "dot -T%s $< > $@" % imagetype,
    )
