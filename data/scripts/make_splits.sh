numsmalltrain=400
numlargetrain=1600
numsmallft=100
numlargeft=400
numtest=1000
numdev=500
foverlap=0.5
outdir=../splits
datadir=../freq_lists
umdir=../unimorph34

echo -e "Language\tSampletype\tSeed\tnumtrainlarge\tnumftlarge\tnumtrainsmall\tnumftsmall\tnumdev\tnumtest\ttestfeatsinlargetrain\tlargetrainfeatsintest\ttestlemmasinlargetrain\tlargetrainlemmasintest\tdevfeatsinlargetrain\tlargetrainfeatsindev\tdevlemmasinlargetrain\tlargetrainlemmasindev\ttestfeatsinsmalltrain\tsmalltrainfeatsintest\ttestlemmasinsmalltrain\tsmalltrainlemmasintest\tdevfeatsinsmalltrain\tsmalltrainfeatsindev\tdevlemmasinsmalltrain\tsmalltrainlemmasindev\ttestfeatsindev\tdevfeatsintest\ttestlemmasindev\tdevlemmasintest\tlargetraintestoverlap\tlargetraindevoverlap\tsmalltraintestoverlap\tsmalltraindevoverlap\tdevtestoverlap" > $outdir/log.tsv

for lang in es de en es tr ar
do	    
    for seed in 0 1 2 3 4
    do
	python3 make_splits.py $datadir/$lang"_freq.txt"  $umdir/$lang"_all.txt" $outdir --small $numsmalltrain --large $numlargetrain --smallfinetune $numsmallft --largefinetune $numlargeft --dev $numdev --test $numtest --foverlap $foverlap --lang $lang --seed $seed
	echo ""
    done
done

#Swahili data is smaller, so large train is reduced in size.
numlargetrain=800
numsmallft=100
numlargeft=200
lang=sw
for seed in 0 1 2 3 4
    do
	python3 make_splits.py $datadir/$lang"_freq.txt" $umdir/$lang"_all.txt" $outdir --small $numsmalltrain --large $numlargetrain --smallfinetune $numsmallft --largefinetune $numlargeft --dev $numdev --test $numtest --foverlap $foverlap --lang $lang --seed $seed
	echo ""
    done

