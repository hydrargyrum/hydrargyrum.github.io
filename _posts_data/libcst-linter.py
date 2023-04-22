#!/usr/bin/env python3

import sys

import libcst
import libcst.matchers as M
from libcst.metadata import PositionProvider, MetadataWrapper


class NoneLinter(libcst.CSTVisitor):
    METADATA_DEPENDENCIES = (PositionProvider,)

    def visit_Comparison(self, node):
        # only accept == and != and no chained-comparisons
        if not M.matches(
            node,
            M.Comparison(
                comparisons=[
                    M.ComparisonTarget(operator=M.OneOf(M.Equal(), M.NotEqual()))
                ],
            ),
        ):
            return True

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
            return True

        pos = self.get_metadata(PositionProvider, node).start
        print(f"{pos.line}: you should use `is None` or `is not None`")

        return True


with open(sys.argv[1]) as fp:
    src_text = fp.read()
src_tree = MetadataWrapper(libcst.parse_module(src_text))
visitor = NoneLinter()
src_tree.visit(visitor)
