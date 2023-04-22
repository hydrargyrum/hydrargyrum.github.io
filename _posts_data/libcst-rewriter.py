#!/usr/bin/env python3

import sys

import libcst
import libcst.matchers as M


TRANSFORMED = {
    libcst.Equal: libcst.Is,
    libcst.NotEqual: libcst.IsNot,
}


class NoneRewriter(libcst.CSTTransformer):
    def leave_Comparison(self, _: libcst.Comparison, node: libcst.Comparison):
        # see https://libcst.readthedocs.io/en/latest/nodes.html#libcst.Comparison

        if (
            # only accept == and !=
            not isinstance(
                node.comparisons[0].operator, (libcst.Equal, libcst.NotEqual)
            )
            # ignore chained-comparisons like `... == ... == ...`
            or len(node.comparisons) > 1
        ):
            return node

        if not (
            M.matches(
                node,
                M.Comparison(
                    comparisons=[M.ComparisonTarget(comparator=M.Name("None"))],
                ),
            )
            # yoda-style: None == ...
            or M.matches(node, M.Comparison(left=M.Name("None")))
        ):
            return node

        new_op_type = TRANSFORMED[type(node.comparisons[0].operator)]
        return node.with_deep_changes(node.comparisons[0], operator=new_op_type())


with open(sys.argv[1]) as fp:
    src_text = fp.read()
src_tree = libcst.parse_module(src_text)
visitor = NoneRewriter()
new_code = src_tree.visit(visitor).code
with open(sys.argv[1], "w") as fp:
    fp.write(new_code)
