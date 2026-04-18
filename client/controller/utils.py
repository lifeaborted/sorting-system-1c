def dict_iterator(d: dict):
    for k, v in d.items():
        if isinstance(v, dict):
            yield from dict_iterator(v)
        else:
            yield k, v
