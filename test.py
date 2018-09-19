
f = open("pagerank_result", "w")
list_pair = [(1,2),(3,4),(5,6)]
for (link, rank) in list_pair:
    print >> f, "%s has rank: %s." % (link, rank)
f.close()
