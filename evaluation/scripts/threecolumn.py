import sys

# This converts Wu et all decoded output files into the standard 3 column format

infname = sys.argv[1]
evalfname = sys.argv[2]
evalfname = evalfname.replace("test","gold")
outfname = sys.argv[3]
outfname = outfname.replace("gold","test")

lemmas = []
feats = []

#print(infname)
#print(evalfname)
#print(outfname)

with open(evalfname, "r") as fin:
    for line in fin:
        l, i, f = line.split("\t")
        lemmas.append(l.strip())
        feats.append(f.strip())
        
with open(infname, "r") as fin:
    with open(outfname, "w") as fout:
        fin.readline()
        for i, line in enumerate(fin):
            try:
                pred, tgt, loss, dist = line.split("\t")
            except ValueError:
                print(line)
                raise ValueError
            if not pred.strip():
                pred = "_"
#            print(pred, i)
#            print(lemmas[i])
#            print(feats[i])
            fout.write("%s\t%s\t%s\n" % (lemmas[i], pred.replace(" ","").strip(), feats[i]))
