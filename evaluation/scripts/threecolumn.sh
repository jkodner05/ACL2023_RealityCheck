indir=../../ACL_CogSci2023_Predictions
modeldir=NeuralPredictions
modelname=wuetal
outdir=../../predictions
golddir=../../data/splits

echo "Acquisition"
for splittype in naive_uniform naive_weighted overlap_aware naive_uniform/acq naive_weighted/acq sigm2022/acq
do
    mkdir -p $outdir/$splittype/$modelname
done

for size in 100 200 300 400 500 600 700 800 900 1000
do
    for evaltype in dev gold
    do
	lang=ara
	seed=sigm2022
	outlang=arN
	python3 threecolumn.py $indir/sigm2022/acq/$modeldir/$lang"_"$seed/$size.$evaltype.decode.tsv $golddir/sigm2022/$lang"_"$seed.$evaltype $outdir/sigm2022/acq/$modelname/$outlang"_"$seed"_"$size.$evaltype
	lang=eng
	seed=sigm2022
	outlang=enV
	python3 threecolumn.py $indir/sigm2022/acq/$modeldir/$lang"_"$seed/$size.$evaltype.decode.tsv $golddir/sigm2022/$lang"_"$seed.$evaltype $outdir/sigm2022/acq/$modelname/$outlang"_"$seed"_"$size.$evaltype
    done
done
for size in 100 200 300 400 500 600
do
    for evaltype in dev gold
    do
	lang=deu
	seed=sigm2022
	outlang=deN
	python3 threecolumn.py $indir/sigm2022/acq/$modeldir/$lang"_"$seed/$size.$evaltype.decode.tsv $golddir/sigm2022/$lang"_"$seed.$evaltype $outdir/sigm2022/acq/$modelname/$outlang"_"$seed"_"$size.$evaltype
    done
done


for splittype in naive_uniform/acq naive_weighted/acq
do
    for seed in 0 1 2 3 4
    do
	for lang in arN enV
	do
	    for size in 100 200 300 400 500 600 700 800 900 1000
	    do
		for evaltype in dev gold
		do
		    python3 threecolumn.py $indir/$splittype/$modeldir/$lang/$seed"_"$size.$evaltype.decode.tsv $golddir/$splittype/$lang"_"$seed.$evaltype $outdir/$splittype/$modelname/$lang"_"$seed"_"$size.$evaltype
		done
	    done
	done
	lang=deN
	for size in 100 200 300 400 500 600
	do
	    for evaltype in dev gold
	    do
		python3 threecolumn.py $indir/$splittype/$modeldir/$lang/$seed"_"$size.$evaltype.decode.tsv $golddir/$splittype/$lang"_"$seed.$evaltype $outdir/$splittype/$modelname/$lang"_"$seed"_"$size.$evaltype
	    done
	done
    done
done



echo "General"
for splittype in naive_uniform naive_weighted overlap_aware
do
    for lang in de en es sw tr ar
    do
	for seed in 0 1 2 3 4
	do
	    for size in large small
	    do
		for evaltype in dev gold
		do
		    python3 threecolumn.py $indir/$splittype/$modeldir/$lang/$seed"_"$size.$evaltype.decode.tsv $golddir/$splittype/$lang"_"$seed.$evaltype $outdir/$splittype/$modelname/$lang"_"$seed"_"$size.$evaltype
		done
	    done
	done
    done
done
