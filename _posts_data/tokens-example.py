
a = 1

b = (
    2
)

c = 3; d = 4

e = \
    \
    5

f = "foo\
    foo"

g = """
    grault
    """

if a:
    pass
    if b:
        pass
        if c:
            pass
            pass
    # comment still not dedented
else:
    pass
    pass

for i in g: pass; pass
else: pass; pass
