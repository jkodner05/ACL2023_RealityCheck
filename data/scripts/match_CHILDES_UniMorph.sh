CHILDESdir=../../data/CHILDES #replace with your own base directory

python3 match_CHILDES_UniMorph.py $CHILDESdir/German/Leo/ ../unimorph34/de_all.txt de_CHILDES-UniMorph.txt
python3 match_CHILDES_UniMorph.py $CHILDESdir/Spanish ../unimorph34/es_all.txt es_CHILDES-UniMorph.txt
python3 match_CHILDES_UniMorph.py $CHILDESdir/English/English-NA ../unimorph34/en_all.txt en_CHILDES-UniMorph.txt

