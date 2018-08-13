def prune(tagfile, srcfile):
    """Prune srcfile related tags from tagfile

    :tagfile: string, tagfile name
    :srcfile: string, source file name
    :returns: none

    """
    try:
        f = open(tagfile, 'r')
    except FileNotFoundError:
        return

    lines = f.readlines()
    f.close()

    f = open(tagfile, 'w')

    t = []
    for line in lines:
        if srcfile not in line:
            t.append(line)

    f.writelines(t)
    f.close()
