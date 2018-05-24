#!/bin/bash
#$ -cwd 


##########################################################################
# Allysia Mak                                                            #
# mutect2.sh runs SplitNCigarReads for read preprocessing before running #
# Mutect2 on all bams in the 'parentdir'                                 #
#                                                                        #
# The number of bams run in parallel is specified by 'numProcesses'      #
##########################################################################


parentdir="/scratch/jakutagawa/RNA-seq/tumor_bams/tcga-bams" #/reindex/
hs37="/pod/pstore/groups/brookslab/reference_indices/hs37/hs37d5.fa"
hg19="/pod/pstore/groups/brookslab/reference_indices/hg19/hg19.fa"
outDir="/scratch/amak/varCalls/Mutect/round-one-results"
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

    echo "SplitNCigarReads running on " $uid
    maxProcesses; nice time gatk SplitNCigarReads -R $hs37 -I $bam -O $parentdir'/'$uid'.split.bam' &
    tumor_ID_line=$(samtools view -H $bam | grep '@RG')
    tumor_ID=${tumor_ID_line##*:}
    echo $tumor_ID

    maxProcesses; nice time gatk Mutect2 -R $hs37 -I $bam -tumor $tumor_ID -O $outDir'/'$uid'/'$uid'.vcf' &
	

#    rm $parentdir'/'$uid'.split.bam'

    echo $uid " complete"


done
wait
