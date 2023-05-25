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

noun_match_rx = re.compile(r"^(n)\|(\w+)(([-&]\w+)*)")
adj_match_rx = re.compile(r"^(adj)\|(\w+)(([-&]\w+)*)")
verb_match_rx = re.compile(r"^(v|imp|inf|mod|cop|part)\|(\w+)(([-&]\w+)*)")


def convert(pos, lemma, feats, unimorphbylemmafeats, lemmas):
    triples = []
    rawfeats = feats
    feats = set(feats.lower().replace("-", "&").split("&"))
    umpos = ""
    if pos == "n":
        umpos = "N"
    if pos in ("v", "imp", "mod", "inf", "cop", "part"):
        umpos = "V"
    number = ""
    gender = ""
    case = ""
    tense = ""
    mood = ""
    person = ""
    if "pl" in feats or "1p" in feats or "2p" in feats or "3p" in feats or "13p" in feats or "23p" in feats:
        number= "PL"
    elif umpos == "N":
        number = "SG"
    if "presp" in feats:
        tense = "PRS"
        mood = "V.PTCP"
    elif "pastp" in feats:
        tense = "PST"
        mood = "V.PTCP"
    elif "past" in feats:
        tense="PST"
    elif umpos == "V":
        tense = "NFIN"
    elif "3s" in feats:
        person = "3"
        number = "SG"
        tense = "PRS"
    elif "inf" in feats or pos == "inf":
        mood = "NFIN"
        tense = ""

    umfeats = []
    if umpos == "N":
        umfeats.extend((umpos,number))
    elif umpos[0] == "V":
        umfeats.extend((umpos,mood,tense,person,number))
    try:
        feats = semicolon_rx.sub(";", ";".join(umfeats))
        if feats[-1] == ";":
            feats = feats[:-1]
        infl = unimorphbylemmafeats[(lemma, feats)]
        triples.append((lemma, infl, feats))
    except KeyError:
        # pass
        # FOR DEBUGGING
        if feats == "N;SG" or feats == "V;NFIN" or feats == "V;PRS":
            triples.append((lemma, lemma, feats))
#        elif lemma in lemmas and (lemma not in ("be","snowman", "lion", "presweeten")):
#            if feats !=  "V;PRS" and feats!="N;PL":
#                print("The infl is missing!", lemma)
#                raise ZeroDivisionError
#        if tense=="PST" and mood == "V.PTCP":
#            print("\tnope", (lemma, feats, gender))
    return triples

def parse_file(fname, freqsbytriple, unimorphbylemmafeats):
    lemmas = set([lemma for lemma, feats in unimorphbylemmafeats.keys()])
    with open(fname, "r") as f:
        speaker = ""
        inmorpho = False
        for line in f:
            if morphline_rx.match(line.strip()):
                inmorpho = True
            elif textline_rx.match(line.strip()):
                textline = line.strip()
                speaker = textline[0:4]
                inmorpho = False
            elif line[0] != "\t":
                inmorpho = False
            for excl in exclude_speakers:
                if excl in speaker:
                    continue

            if inmorpho:
                rawwords = line.strip()[6:].split()
                for word in rawwords:
                    components = word.split("#")
                    word = components[-1]
                    prefix = "".join(components[:-1])
                    noun_match = noun_match_rx.search(word)
                    verb_match = verb_match_rx.search(word)
                    pos = ""
                    lemma = ""
                    feats = ""
#                    print(word, noun_match, verb_match)
                    if noun_match:
#                        print(word, noun_match.group(1), noun_match.group(2), noun_match.group(3))
                        pos = noun_match.group(1)
                        lemma = noun_match.group(2)
                        feats = noun_match.group(3)
                    elif verb_match:
#                        print(word, verb_match.group(1), verb_match.group(2), verb_match.group(3))
                        pos = verb_match.group(1)
                        lemma = verb_match.group(2)
                        feats = verb_match.group(3)
#                        print(pos, lemma, feats)

                    if pos:
                        triples = convert(pos, prefix+lemma, feats, unimorphbylemmafeats, lemmas)
                        for triple in triples:
                            freqsbytriple[triple] += 1/len(triples)



