assert any(
    el == None
    for el in [
        range != None,
        range is None,
        None == range,
    ]
)
