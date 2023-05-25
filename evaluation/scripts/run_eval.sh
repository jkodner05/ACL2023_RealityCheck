preddir=../../predictions
golddir=../../data/splits
resultsdir=../summary_results


for splittype in naive_uniform naive_weighted overlap_aware
do
    mkdir -p $resultsdir/$splittype
done

echo "General"
rm $resultsdir/eval_.tsv
for model in nonneur wuetal cluzh-b4 cluzh-gr 
do
    for splittype in naive_uniform naive_weighted overlap_aware
    do
	for evaltype in dev test
	do
	    outfname=$resultsdir/$splittype/$model.$evaltype.tsv
	    python3 evaluate.py $preddir/$splittype/$model $golddir/$splittype --evaltype $evaltype  --modelname $model --splittype $splittype > $outfname
	    tail -n +2 $outfname >> $resultsdir/eval_.tsv
	    #python3 evaluate.py $preddir/$splittype/$model $golddir/$splittype --evaltype $evaltype --partition _small _large _0 _1 de en es sw tr de_small en_small es_small sw_small tr_small de_large en_large es_large sw_large tr_large 0_small 1_small 0_large 1_large> $resultsdir/$splittype/$model.tsv
	done
    done
done
head -n 1 $resultsdir/naive_uniform/nonneur.test.tsv > header
cat header $resultsdir/eval_.tsv > $resultsdir/eval.tsv
