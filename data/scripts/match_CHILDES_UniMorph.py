import argparse, re, os
from os.path import basename
from collections import defaultdict
import statistics
import numpy as np
import sys

exclude_speakers = set(["CHI"])

textline_rx = re.compile(r"^\*[A-Z][A-Z][A-Z]:")
morphline_rx = re.compile(r"^%mor:")
semicolon_rx = re.compile(r";+")


def count_types(basedir, unimorphbylemmafeats):

    freqsbytriple = defaultdict(int)

    fnames = []
    oldnum = 0
    for subdir, dirs, files in os.walk(basedir):
        for fname in files:
            if ".cha" in fname:
                parse_file(os.path.join(subdir, fname), freqsbytriple, unimorphbylemmafeats)
                fnames.append(os.path.join(subdir, fname))
                newnum = sum(freqsbytriple.values())
                if newnum > oldnum:
                    print(os.path.join(subdir,fname))
                oldnum = newnum

    return dict(freqsbytriple)



def read_unimorph(unimorphfname):
    unimorphbylemmafeats = {}
    numduplicated = 0
    numadded = 0
    with open(unimorphfname, "r") as fin:
        for line in fin:
            if line.strip():
                lemma, form, feats = line.strip().split("\t")
                # Delete  UniMorph gender so it can be replaced with CHILDES gender
                if "deu" in unimorphfname:
                    feats = feats.replace(";FEM;", ";").replace(";MASC;", ";").replace(";NEUT;", ";").replace(";FEM+NEUT;", ";").replace(";MASC+NEUT;", ";").replace(";MASC+FEM;", ";").replace(";MASC+FEM+NEUT;", ";")
                elif "spa" in unimorphfname:
                    if "MASC+FEM" in feats or "FEM+MASC" in feats:
                        feats = feats.replace("MASC+FEM","MASC").replace("FEM+MASC","MASC")
                        if (lemma, feats) in unimorphbylemmafeats:
        #                    print("DUPLICATE!!! ", (lemma, feats), unimorphbylemmafeats[(lemma, feats)])
                            numduplicated += 1
                        else:
                            unimorphbylemmafeats[(lemma, feats)] = form
                            numadded += 1
                        feats = feats.replace("MASC","FEM")
                if (lemma, feats) in unimorphbylemmafeats:
#                    print("DUPLICATE!!! ", (lemma, feats), unimorphbylemmafeats[(lemma, feats)])
                    numduplicated += 1
                else:
                    unimorphbylemmafeats[(lemma, feats)] = form
                    numadded += 1
    print(numadded, numduplicated)
    return unimorphbylemmafeats

def writeout(outfname, freqsbytriple):
    sortedentries = sorted(freqsbytriple.items(), key=lambda kv: kv[1], reverse=True)
    with open(outfname, "w") as f:
        for entry, freq in sortedentries:
            f.write("%s\t%s\n" % ("\t".join(entry).strip(), freq))


if __name__ == "__main__":

    datadir = sys.argv[1]
    unimorphfname = sys.argv[2]
    outfname = sys.argv[3]


    unimorphbylemmafeats = read_unimorph(unimorphfname)

    if "de" in unimorphfname:
        from de_match_CHILDES_UniMorph import parse_file, convert
        print("German")
    elif "en" in unimorphfname:
        from en_match_CHILDES_UniMorph import parse_file, convert
        print("English")
    elif "es" in unimorphfname:
        from es_match_CHILDES_UniMorph import parse_file, convert
        print("Spanish")


    freqsbytriple = count_types(datadir, unimorphbylemmafeats)

    print(freqsbytriple)
    print(len(freqsbytriple))

    writeout(outfname, freqsbytriple)
