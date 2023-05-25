import re
from datasets import load_dataset

# requires the following libraries
# $ pip3 install apache_beam mwparserfromhell
# $ pip3 install datasets
# And unimorph swc https://github.com/unimorph/swc/commit/02a2bdec0e5cb0dc93b6ef11db4d54a82c34b224
# cat swc-master/swc_all | sort | uniq > swc-master/swc_combined

wikidump = "20221201"
wikilang = "sw"
unimorphfname = "swc-master/swc_combined"
#wikilang = "tr"
#unimorphfname = "tur-master/tur"


def read_unimorph(unimorphfname):
    unimorph = {}
    with open(unimorphfname, "r") as fin:
        for line in fin:
            if line.strip():
                lemma, infl, feats = line.strip().split("\t")
#                if "ARGNO3S" in feats:
#                    continue
                if infl not in unimorph:
                    unimorph[infl] = set([])
                unimorph[infl].add((lemma, feats))
#    for infl, pairs in unimorph.items():
#        if len(pairs) > 1:
#            print(infl, pairs)
    return unimorph

def tokenize_wiki(wikidump, wikilang):
    wiki = load_dataset('wikipedia', date=wikidump,
                        language=wikilang, split='train',
                        beam_runner='DirectRunner') #there is no test, only train
    nopunct_rx = re.compile(r"[^A-Za-z-]")
    noenddash_rx = re.compile(r"-+$")
    tokenfreqs = {}
    for doc in wiki["text"]:
    #    print(len(doc.split()))
        for token in doc.lower().split():
            cleanedtoken = nopunct_rx.sub("", token)
            cleanedtoken = noenddash_rx.sub("", cleanedtoken)
            if cleanedtoken not in tokenfreqs:
                tokenfreqs[cleanedtoken] = 0
            tokenfreqs[cleanedtoken] += 1
    return tokenfreqs

def merge(unimorph, wiki):
    freqdict = {}
    numattested = 0
    attestedlemmas = set([])
    attestedinfls = set([])
    for infl, freq in wiki.items():
        if infl in unimorph:
            pairs = unimorph[infl]
            for lemma, feats in pairs:
                freqdict[(lemma, infl, feats)] = freq/len(pairs)
                attestedlemmas.add(lemma)
                attestedinfls.add(infl)
        numattested += 1
    print("infltokens:", numattested, "infltypes:", len(attestedinfls), "lemmatypes:", len(attestedlemmas))
    return freqdict

unimorph = read_unimorph(unimorphfname)
wiki = tokenize_wiki(wikidump, wikilang)
freqdict = merge(unimorph, wiki)

sortedtriples = sorted(freqdict.items(), key=lambda kv: kv[1], reverse=True)

print("tripletypes:", len(sortedtriples))


with open("%s_freq.txt" % wikilang, "w") as fout:
    for triple, freq in sortedtriples:
        fout.write("%s\t%s\t%s\t%s\n" % (triple[0], triple[1], triple[2], freq))
    
