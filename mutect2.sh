#!/bin/bash
#$ -cwd 


##########################################################################
# Allysia Mak                                                            #
# mutect2.sh runs SplitNCigarReads for read preprocessing before running #
# Mutect2 on all bams in the 'parentdir'                                 #
#                                                                        #
# The number of bams run in parallel is specified by 'numProcesses'      #
##########################################################################

tumordir="/scratch/jakutagawa/RNA-seq/realigned_bams/tumor"
normaldir="/scratch/jakutagawa/RNA-seq/realigned_bams/normal"
hs37="/pod/pstore/groups/brookslab/reference_indices/hs37/hs37d5.fa"
hg19="/pod/pstore/groups/brookslab/reference_indices/hg19/hg19.fa"
outDir="/scratch/amak/varCalls/Mutect/normal-vcfs"
numProcesses=2


function maxProcesses {
    # Waits until there are less than 'numProcesses' jobs running before starting a new job

    while [ $(jobs | wc -l) -ge 2 ]; do
	echo 'waiting'
	sleep 5

    done
}

for bam in $(find $normaldir -mindepth 1 -name '*hs37d.bam'); do
    uid=$(basename $bam)
    IFS='.'
    set $uid
    uid=$(echo $1)
    unset IFS
    bamdir=$(dirname $bam)


    echo "SplitNCigarReads running on " $uid
#    maxProcesses; sleep 10 
    maxProcesses; nice time gatk SplitNCigarReads -fixNDN -R $hs37 -I $bam -O $bamdir'/'$uid'.split.bam' &
    echo $(find $normaldir -name $uid'.split.bam')

done
wait

for bam in $(find $normaldir -mindepth 1 -name '*hs37d.bam'); do
    uid=$(basename $bam)
    IFS='.'
    set $uid
    uid=$(echo $1)
    unset IFS
    bamdir=$(dirname $bam)

    mkdir $outDir/$uid
    normal_ID_line=$(samtools view -H $bam | grep '@RG')
#    normal_ID=${normal_ID_line##*:}
    IFS=$':\t'
    set $normal_ID_line
    
    normal_ID=$(echo $6)
    unset IFS
#    maxProcesses; sleep 10 
    maxProcesses; nice time gatk Mutect2 -R $hs37 -I $bamdir'/'$uid'.split.bam' -tumor $normal_ID -O $outDir'/'$uid'/'$uid'.vcf' &


#    rm $tumordir'/'$uid'.split.bam'                                                                                                          

    echo $uid " complete"


done
wait
