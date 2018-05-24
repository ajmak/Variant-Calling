#!/bin/bash
#$ -cwd 


##########################################################################
# Allysia Mak                                                            #
# platypus.sh runs Opposum for read preprocessing before running         #
# Platypus on all bams in the 'parentdir'                                #
#                                                                        #
# The number of bams run in parallel is specified by 'numProcesses'      #
##########################################################################


parentdir="/scratch/jakutagawa/RNA-seq/tumor_bams/tcga-bams" #/reindex/
hs37="/pod/pstore/groups/brookslab/reference_indices/hs37/hs37d5.fa"
hg19="/pod/pstore/groups/brookslab/reference_indices/hg19/hg19.fa"
outDir="/scratch/amak/varCalls/Platypus/round-one-results"
opossum="/pod/pstore/groups/brookslab/amak/packages/Opossum/Opossum.py"
platypus="/pod/pstore/groups/brookslab/amak/packages/.py"
numProcesses=4


function maxProcesses {
    # Waits until there are less than 'numProcesses' jobs running before starting a new job
    while [ 'jobs | wc -l' -ge $numProcesses]; do
	sleep 5
    done
}

for bam in $(find $parentdir -mindepth 1 -name '*.bam'); do
    uid=$(basename $bam)

#    mkdir $outDir/$uid
    echo "Opossum running on " $uid
    if [[ $uid == *"STAR*"* ]]; then
	maxProcesses; nice time python opossum --BamFile=$bam --SoftClipsExist=True --OutFile=$parentdir'/'$uid'.opossum.bam' &
    else
	maxProcesses; nice time python opossum --BamFile=$bam --SoftClipsExist=False --OutFile=$parentdir'/'$uid'.opossum.bam' &
    fi

    echo "Platypus running on " $uid

    maxProcesses; nice time platypus --callVariants --bamFiles $bam --refFile $hs37 --filterDuplicates 0 --minMapQual 0 --minFlank 0 --maxReadLength 500 --minGoodQualBases 10 --minBaseQual 20 -o $outDir'/'$uid'.vcf' &
	

#   rm $parentdir'/'$uid'.opossum.bam'

    echo $uid " complete"


done
wait
