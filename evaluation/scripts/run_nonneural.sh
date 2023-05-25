preddir=../../predictions
golddir=../../data/splits

for splittype in naive_uniform naive_weighted overlap_aware naive_uniform/acq naive_weighted/acq sigm2022/acq
do
    mkdir -p $preddir/$splittype/nonneur
done


for splittype in  naive_uniform naive_weighted overlap_aware naive_uniform/acq naive_weighted/acq 
do
    python3 nonneural.py --output $preddir/$splittype/nonneur/ --path $golddir/$splittype/ -t
    python3 nonneural.py --output $preddir/$splittype/nonneur/ --path $golddir/$splittype/
    rm $preddir/$splittype/nonneur/*_5_*
    rm $preddir/$splittype/nonneur/*_6_*
    rm $preddir/$splittype/nonneur/*_7_*
done

python3 nonneural.py --output $preddir/sigm2022/acq/nonneur/ --path $golddir/sigm2022/ -t
python3 nonneural.py --output $preddir/sigm2022/acq/nonneur/ --path $golddir/sigm2022/


for size in 100 200 300 400 500 600 700 800 900 1000
do
    for evaltype in dev test
    do
	mv $preddir/sigm2022/acq/nonneur/ara_sigm2022_$size.$evaltype $preddir/sigm2022/acq/nonneur/arN_sigm2022_$size.$evaltype
	mv $preddir/sigm2022/acq/nonneur/deu_sigm2022_$size.$evaltype $preddir/sigm2022/acq/nonneur/deN_sigm2022_$size.$evaltype
	mv $preddir/sigm2022/acq/nonneur/eng_sigm2022_$size.$evaltype $preddir/sigm2022/acq/nonneur/enV_sigm2022_$size.$evaltype
    done
done
