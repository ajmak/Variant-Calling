#!/bin/bash
#$ -cwd 


##########################################################################
# Allysia Mak                                                            #
# platypus.sh runs Opposum for read preprocessing before running         #
# Platypus on all bams in the 'parentdir'                                #
#                                                                        #
# The number of bams run in parallel is specified by 'numJobs'           #
##########################################################################


#parentdir="/scratch/jakutagawa/RNA-seq/realigned_bams/tumor"
parentdir="/scratch/jakutagawa/RNA-seq/realigned_bams/normal"
hs37="/pod/pstore/groups/brookslab/reference_indices/hs37/hs37d5.fa"
hg19="/pod/pstore/groups/brookslab/reference_indices/hg19/hg19.fa"
outDir="/scratch/amak/varCalls/Platypus/normal-vcfs"
opossum="/pod/pstore/groups/brookslab/amak/packages/Opossum/Opossum.py"
platypus="/pod/pstore/groups/brookslab/amak/packages/Platypus/bin/Platypus.py"
#Specify here the number of concurrent jobs
maxProcesses=$1
if [ $maxProcesses -eq 0 ]; then
    echo "Max number of processes not supplied. Defaulting to 4"
    maxProcesses=4
fi


function maxJobs {
    # Waits until there are less than 'numJobs' jobs running before starting a new job
    while [ $(jobs | wc -l) -ge $maxProcesses ]; do
	echo 'waiting'
	sleep 5
    done
}

for bam in $(find $parentdir -mindepth 1 -name '*hs37d5.bam'); do
    uid=$(basename $bam)
    IFS='.'
    set $uid
    uid=$(echo $1)
    unset IFS
    bamdir=$(dirname $bam)

#    mkdir $outDir/$uid
    echo "Opossum running on " $uid
    if [[ $uid == *"tophat"* ]]; then
	maxJobs; nice time python $opossum --BamFile=$bam --SoftClipsExist=False --OutFile=$bamdir'/'$uid'.opossum.bam' &
    else
	maxJobs; nice time python $opossum --BamFile=$bam --SoftClipsExist=True --OutFile=$bamdir'/'$uid'.opossum.bam' &
    fi

done
wait

for bam in $(find $parentdir -mindepth 1 -name '*hs37d.bam'); do
    uid=$(basename $bam)
    IFS='.'
    set $uid
    uid=$(echo $1)
    unset IFS
    bamdir=$(dirname $bam)
    mkdir $outDir/$uid
    echo "Platypus running on " $uid

    maxJobs; nice time python $platypus callVariants --bamFiles $bamdir'/'$uid'.opossum.bam' --refFile $hs37 --filterDuplicates 0 --minMapQual 0 --minFlank 0 --maxReadLength 500 --minGoodQualBases 10 --minBaseQual 20 -o $outDir'/'$uid'/'$uid'.vcf' &

#   rm $parentdir'/'$uid'.opossum.bam'                            

    echo $uid " complete"
done
wait
