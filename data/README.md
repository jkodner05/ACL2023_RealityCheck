## Data

### Frequency-sorted lists

* Arabic - ``ar_freq.txt`` - PATB x UniMorph 4 ara_new+atb
* English - ``en_freq.txt`` - from CHILDES all English-NA x UniMorph 3+4
* German - ``de_freq.txt`` - From CHILDES LEO x UniMorph 3+4
* Spanish - ``es_freq.txt`` - generated from all Spanish CHILDES x UniMorph 3+4
* Swahili - ``sw_freq.txt`` - From Wikipedia x UniMorph 4
* Turkish - ``tr_freq.txt`` - from Wikipedia x UniMorph 4


## Scripts

### Freq list generation

* ``wiki_to_UMfreq.py`` generates frequency sorted UniMorph-style lists by intersecting Wikipedia dumps with UniMorph files. Swahili was intersection with combined swc and swc.sm from UniMorph.
* ``match_CHILDES_UniMorph.py`` and ``match_CHILDES_UniMorph.py`` generates data from all non-CHI speakers in CHILDES x UniMorph
* ``de_match_CHILDES_UniMorph.py`` German-specific functions for ``match_CHILDES_Unimorph.py`` Only N and V because Leo's adjective annotation is a mess. UniMorph 
* ``en_match_CHILDES_UniMorph.py`` English-specific functions for ``match_CHILDES_Unimorph.py`` Only N and V for consistency with German. UniMorph 3+4
* ``es_match_CHILDES_UniMorph.py`` Spanish-specific functions for ``match_CHILDES_Unimorph.py`` Only N and V for consistency with German. UniMorph 3+4


### Splitting

See ``data/splits/README.md`` for more information on file formats and naming conventions.

* ``make_splits.py`` - script to make all of the seeded data splits for ar, de, en, es, sw, tr
* ``make_splits.sh`` - runs the above script with parameters for every language

## Data Sources

### Arabic UniMorph x PATB

* UniMorph 4 ara + ara_new
* Penn Arabic Treebank (PATB; Maamouri et al., 2004)

### English UniMorph x CHILDES

* UniMorph 4 + UniMorph 3 normalized
* All English-NA CHILDES corpora with ``%mor`` tiers (see paper for list).
* Nouns and verbs only.

### German UniMorph x CHILDES

* UniMorph 4 + UniMorph 3 normalized
* Leo Corpus (Behrens, 2006)
* Nouns and verbs only.

### Spanish UniMorph x CHILDES

* UniMorph 4 + UniMorph 3 normalized
* All Spanish CHILDES with ``%mor`` tiers (see paper for list).
* Nouns and verbs only.

### Swahili UniMorph x Wikipedia

* UniMorph 4 swc + swc.sm
* Huggingface Wikipedia dump ``20221201``

### Turkish UniMorph x Wikipedia

* UniMorph 4
* Huggingface Wikipedia dump ``20221201``

