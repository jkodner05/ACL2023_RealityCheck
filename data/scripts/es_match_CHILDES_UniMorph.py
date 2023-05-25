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
verb_match_rx = re.compile(r"^(v|imp|inf|mod|cop|part)\|(\w+)(([-&]\w+)+)(~pro:clit\|([^=]+))?")


def convert(pos, lemma, feats, cltfeats, unimorphbylemmafeats, lemmas):

    def add_reflexive(lemma, umfeats, clitic, unimorphbylemmafeats):
        if (lemma, umfeats+clitic) not in unimorphbylemmafeats:
            if lemma[-1] == "r" and lemma[-2] in ("a", "i", "e"):
                if (lemma+"se", umfeats+clitic) in unimorphbylemmafeats or (lemma+"se", umfeats) in unimorphbylemmafeats:
                    lemma += "se"
        return lemma

    triples = []
    rawfeats = feats
    feats = set(feats.lower().replace("-", "&").split("&"))
    umpos = ""
    if pos == "n":
        umpos = "N"
    if pos in ("v", "imp", "mod", "inf", "cop", "part"):
        umpos = "V"
        lemma += "r"
    number = ""
    gender = ""
    case = ""
    tense = ""
    mood = ""
    persons = ("",)
    aspect = ""

    clitic = ""
    clitic_extra = ""

    if cltfeats:
        cltfeats = set(cltfeats.lower().replace("-", "&").split("&"))
        if "obj" in cltfeats:
            clitic = ";ACC;PRO;"
            clitic_extra = clitic
        elif "refl" in cltfeats:
            clitic = ";DAT;PRO;"
            clitic_extra = ";REFL;PRO;"
        else:
            clitic = ";DAT;PRO;"
            clitic_extra = clitic
        if "m" in  cltfeats:
            clitic += "3;"
            clitic_extra += "3;"
            clitic_extra += "MASC;"
        elif "f" in cltfeats:
            clitic += "3;"
            clitic_extra += "3;"
            clitic_extra += "FEM;"
        if "3s" in cltfeats or "3p" in cltfeats:
            if "3;" not in clitic:
                clitic += "3;"
                clitic_extra += "3;"
        elif "2s" in cltfeats or "2p" in cltfeats:
            clitic += "2;"
            clitic_extra += "2;"
        elif "1s" in cltfeats or "1p" in cltfeats:
            clitic += "1;"
            clitic_extra += "1;"
        if "pl" in cltfeats or "1p" in cltfeats or "2p" in cltfeats or "3p" in cltfeats:
            clitic += "PL"
            clitic_extra += "PL"
        elif "3s" in cltfeats or "1s" in cltfeats or "2s" in cltfeats or "m" in cltfeats or "f" in cltfeats:
            clitic +=  "SG"
            clitic_extra += "SG"

    if "pl" in feats or "1p" in feats or "2p" in feats or "3p" in feats:
        number= "PL"
    elif "3s" in feats or "1s" in feats or "2s" in feats or "13s" in feats:
        number = "SG"
    elif umpos == "N" or "ppart" in feats:
        number = "SG"
    if "m" in feats:
        gender = "MASC"
    elif "f" in feats:
        gender = "FEM"
    if "3s" in feats or "3p" in feats:
        persons = ("3",)
    elif "2s" in feats or "2p" in feats:
        persons = ("2",)
        number += ";INFM"
#        if number == "SG" or ("imp" in feats):
    elif "1s" in feats or "1p" in feats:
        persons = ("1",)
    elif "13s" in feats:
        persons = ("1","3")

    if "pres" in feats:
        tense = "PRS"
        mood = "IND"
    elif "pas" in feats:
        tense = "PST"
        mood = "IND"
        aspect = "IPFV"
    elif "pret" in feats:
        tense = "PST"
        mood = "IND"
        aspect = "PFV"
    elif "fut" in feats:
        tense = "FUT"
        mood = "IND"
    elif "cond" in feats:
        tense = "COND"
    if "sub" in feats:
        mood = "SBJV"
        if aspect == "IPFV":
            aspect = "LGSPEC1"
    if "imp" in feats:
        if not clitic:
            mood = "POS;IMP"
            if "3s" in feats or "3p" in feats:
                persons = ("2",)
                number += ";FORM"
        else:
            mood = "IMP"
            if "INFM" in number:
                mood = "IMP;INFM"
                number = number.replace(";INFM","")
            if "3s" in feats or "3p" in feats:
                persons = ("2",)
                mood = "IMP;FORM"

        
    if "inf" in feats or pos == "inf":
        if not clitic:
            mood = "NFIN"
        else:
            mood = ""
        tense = ""
        person = ""
        number = ""
        aspect = ""
    elif "prpart" in feats:
        mood = "V.CVB"
        tense = "PRS"
        gender = ""
        person = ""
        number = ""
        aspect = ""
    elif "ppart" in feats:
        mood = "V.PTCP"
        tense = "PST"
        person = ""
        aspect = ""

    for person in persons:
        umfeats = []
        if umpos == "N":
            umfeats.extend((umpos,gender,number))
        elif umpos[0] == "V":
            umfeats.extend((umpos,mood,tense,aspect,person,gender,number))
        try:
            umfeats = semicolon_rx.sub(";", ";".join(umfeats))
            if umfeats[-1] == ";":
                umfeats = umfeats[:-1]
            lemma = add_reflexive(lemma, umfeats, clitic, unimorphbylemmafeats)
            infl = unimorphbylemmafeats[(lemma, umfeats+clitic)]
            triples.append((lemma, infl, umfeats+clitic_extra))
        except KeyError:
            redo = False
            if (lemma,umfeats.replace("MASC","FEM")) in unimorphbylemmafeats:
                umfeats = umfeats.replace("MASC","FEM")
                redo = True
            elif (lemma,umfeats.replace("FEM","MASC")) in unimorphbylemmafeats:
                umfeats = umfeats.replace("FEM","MASC")
                redo = True
            if clitic:
                redo = True
#                print("\tNo clitic. Redoing without.")
                if umfeats == "V":
                    umfeats += ";NFIN"
                elif umfeats == "V;IMP;INFM;2;SG":
                    umfeats = "V;POS;IMP;2;SG;INFM"
                elif umfeats == "V;IMP;INFM;2;PL":
                    umfeats = "V;POS;IMP;2;PL;INFM"
                elif umfeats == "V;IMP;FORM;2;SG":
                    umfeats = "V;POS;IMP;2;SG;FORM"
                elif umfeats == "V;IMP;FORM;2;PL":
                    umfeats = "V;POS;IMP;2;PL;FORM"
            if "IMP;2;SG;FORM" in umfeats:
                umfeats = umfeats.replace("2;SG;FORM","3;SG")
                redo = True
            elif "IMP;2;PL;FORM" in umfeats:
                umfeats = umfeats.replace("2;PL;FORM","3;PL")
                redo = True
            if redo:
                lemma = add_reflexive(lemma, umfeats, clitic, unimorphbylemmafeats)
                try:
                    infl = unimorphbylemmafeats[(lemma, umfeats)]
                    triples.append((lemma, infl, umfeats))
                except KeyError:
                    pass
#                    if cltfeats:
#                        print("\tnope", (lemma, feats, umfeats, clitic))
#            #FOR DEBUGGING
#            elif lemma in lemmas and (lemma not in ("tragón", "fenomenal", "mates","cotorro", "prismáticos", "semejante", "anís", "cardinal", "querer","alar", "arar", "boto","hinchado","inofensivo","tibio","agachado","enfermo","majo","cambiador")):
#                if (lemma,umfeats.replace("MASC","FEM").replace("N;","ApDJ;")) not in unimorphbylemmafeats and umfeats != "N;SG" and umfeats != "N;PL" and umfeats != "V;POS;IMP" and (lemma, umfeats.replace("N;","ADJ;")) not in unimorphbylemmafeats and "N;" not in umfeats:
#                    print("The infl is missing!", lemma)
#                    raise ZeroDivisionError
#            #FOR DEBUGGING
#            if not redo: #tense=="PST" and mood == "V.PTCP":
#                if cltfeats:
#                    print("\tnope", (lemma, feats, umfeats+clitic))
    return triples

def parse_file(fname, freqsbytriple, unimorphbylemmafeats):
    lemmas = set([lemma for lemma, feats in unimorphbylemmafeats.keys()])
    if "Koine" in fname or "Vila" in fname: # no %mor tier
        return
    with open(fname, "r") as f:
        speaker = ""
        inmorpho = False
        for i, line in enumerate(f):
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
                        cltfeats = ""
                    elif verb_match:
#                            print(word, verb_match.group(1), verb_match.group(2), verb_match.group(3), verb_match.group(6))
                        pos = verb_match.group(1)
                        lemma = verb_match.group(2)
                        feats = verb_match.group(3)
                        cltfeats = verb_match.group(6)
#                        print(pos, lemma, feats)

                    if pos:
                        triples = convert(pos, prefix+lemma, feats, cltfeats, unimorphbylemmafeats, lemmas)
                        for triple in triples:
                            freqsbytriple[triple] += 1/len(triples)



