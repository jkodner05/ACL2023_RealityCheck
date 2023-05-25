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

noun_match_rx = re.compile(r"^(n)\|(\w+)(([-&]\w+)+)")
adj_match_rx = re.compile(r"^(adj)\|(\w+)(([-&]\w+)+)")
cnoun_match_rx = re.compile(r"^(n\|\+n)\|(\w+)\+n\|(\w+)(([-&]\w+)+)")
verb_match_rx = re.compile(r"^(v|imp|inf|mod|cop|part)\|(\w+)(([-&]\w+)+)")


def convert(pos, lemma, feats, unimorphbylemmafeats, lemmas):
    triples = []
    feats = set(feats.lower().replace("-", "&").split("&"))
    umpos = ""
    if pos == "n":
        umpos = "N"
    if pos in ("v", "imp", "mod", "inf", "cop"):
        umpos = "V"
    if pos == "part":
        umpos = "V.PTCP"
    numbers = []
    gender = ""
    case = ""
    tense = ""
    mood = ""
    persons = []
    if "pl" in feats or "1p" in feats or "2p" in feats or "3p" in feats or "13p" in feats or "23p" in feats:
        persons = ("x",)
        numbers = ("PL",)
    elif "sg" in feats or "1s" in feats or "2s" in feats or "3s" in feats or "13s" in feats or "23s" in feats or "3s2p" in feats:
        persons = ("x",)
        numbers = ("SG",)
    if "f" in feats:
        gender = "FEM"
    elif "m" in feats:
        gender = "MASC"
    elif "n" in feats:
        gender = "NEUT"
    if "nom" in feats:
        case = "NOM"
    elif "acc" in feats:
        case = "ACC"
    elif "gen" in feats:
        case = "GEN"
    elif "dat" in feats:
        case = "DAT"
    mood = ""
    if pos != "part":
        mood = "IND"
    if "konj" in feats:
        mood = "SBJV"
    if pos == "imp":
        mood = "IMP"
    if pos == "inf":
        mood = "NFIN"
    else:
        if "pres" in feats or mood == "SBJV":
            tense = "PRS"
        if "past" in feats or "pastp1" in feats or "pastp2" in feats:
            tense = "PST"
        if pos != "part":
            if "1s" in feats or "1p" in feats:
                persons = ("1",)
            elif "2s" in feats or "2p" in feats:
                persons = ("2",)
            elif "3s" in feats or "3p" in feats:
                persons = ("3",)
            elif "13s" in feats:
                persons = ("1","3")
            elif "23s" in feats:
                persons = ("2","3")
            elif "13p" in feats:
                persons = ("1","3")
            elif "23p" in feats:
                persons = ("2","3")
            numbers = numbers*len(persons)
            if "2s3p" in feats:
                persons = ("2","3")
                numbers = ("SG", "PL")
            if "3s2p" in feats:
                persons = ("3","2")
                numbers = ("SG", "PL")
    for person, number in zip(persons,numbers):
        umfeats = []
        if umpos == "N":
            if not (case and gender and number):
                continue
            lemma = lemma.capitalize()
            umfeats.extend((umpos,case,number))
        elif umpos[0] == "V":
            umfeats.extend((umpos,mood,number,person,tense))
        try:
            feats = semicolon_rx.sub(";", ";".join(umfeats))
            if feats[-1] == ";":
                feats = feats[:-1]
            infl = unimorphbylemmafeats[(lemma, feats)]
            if umpos == "N":
                umfeats.insert(len(umfeats)-1, gender)
                feats = semicolon_rx.sub(";", ";".join(umfeats))
            triples.append((lemma, infl, feats))
        except KeyError:
            pass
# FOR DEBUGGING
#            if lemma in lemmas and (lemma not in ("Dunkel", "Mund", "Stift", "Essen", "Jenseits", "Kacke","kommen", "angesehen", "öffnen", "passen", "gelassen", "gelegen", "fassen", "abgelegen","verlassen", "verfressen","besoffen","Leute","Ruhe", "Vieh","verstehen")):
#                if mood != "IMP" and feats != "V;IND;PL;1;PRS" and feats != 'V;IND;PL;3;PRS' and feats != 'V;IND;SG;3;PRS':
#                    print("The infl is missing!", lemma)
#                    raise ZeroDivisionError
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
                    cnoun_match = cnoun_match_rx.search(word)
                    noun_match = noun_match_rx.search(word)
                    verb_match = verb_match_rx.search(word)
                    pos = ""
                    lemma = ""
                    feats = ""
                    if noun_match:
                        print(word, noun_match.group(1), noun_match.group(2), noun_match.group(3))
                        pos = noun_match.group(1)
                        lemma = noun_match.group(2)
                        feats = noun_match.group(3)
                    elif verb_match:
                        print(word, verb_match.group(1), verb_match.group(2), verb_match.group(3))
                        pos = verb_match.group(1)
                        lemma = verb_match.group(2)
                        feats = verb_match.group(3)
#                        print(pos, lemma, feats)

                    if pos:
                        triples = convert(pos, prefix+lemma, feats, unimorphbylemmafeats, lemmas)
                        for triple in triples:
                            freqsbytriple[triple] += 1/len(triples)

                    if cnoun_match:
                        pos = "n"
                        feats = cnoun_match.group(4)
                        for link in ("", "es", "s", "en", "n", "e"):
                            lemma = cnoun_match.group(2) + link + cnoun_match.group(3)

                            triples = convert(pos, prefix+lemma, feats, unimorphbylemmafeats, lemmas)
                            for triple in triples:
                                freqsbytriple[triple] += 1

