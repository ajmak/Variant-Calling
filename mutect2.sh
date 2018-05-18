#!/bin/bash
#$ -cwd 


#outputs concatenated vardict file for now, hopefully vcf soon

parentdir="/scratch/jakutagawa/RNA-seq/tumor_bams/reindex/"
hs37="/pod/pstore/groups/brookslab/reference_indices/hs37/hs37d5.fa"
#hg19="/pod/pstore/groups/brookslab/reference_indices/hg19/hg19.fa"
outDir="/scratch/amak/varCalls/Mutect/round-one-results"

for bam in $(find $parentdir -mindepth 1 -name '*sorted.bam'); do
    uid=$(basename $bam)

    mkdir $outDir/$uid

    echo "SplitNCigarReads running on " $uid
    nice time gatk SplitNCigarReads -R $hs37 -I $bam -O $parentdir'/'$uid'.split.bam'
    tumor_ID_line=$(samtools view -H $bam | grep '@RG')
    IFS=':'
    set $tumor_ID_line
    tumor_ID=$(tumor_ID_line[-1])
	

    nice time gatk Mutect2 -R $hs37 -I $bam -tumor $tumor_ID -O $uid'.vcf'
	
#	nice time vardict -D -G $hg19 -f 0.01 -N $uid -b $bam -c 1 -S 2 -E 3 $splitbeds/$bed >> $outDir/$uid/$uid".out" &
	wait 

    rm $parentdir'/'$uid'.split.bam'
    done
    echo $uid " complete"
#    cat $outDir/$uid/* > $outDir/$uid/
done


#time /scratch/amak/packages/VarDictJava/VarDict/vardict -D -G /pod/pstore/groups/brookslab/reference_indices/hg19/hg19.fa -f 0.01 -N PCAWG.ba92c434-3604-4b85-bc76-3bbe5c44253f.TopHat2.v1.chr.sorted -b /scratch/jakutagawa/RNA-seq/tumor_bams/reindex/c1b68b54-0258-470b-b6e2-b3f558bb1293/PCAWG.ba92c434-3604-4b85-bc76-3bbe5c44253f.TopHat2.v1.chr.sorted -c 1 -S 2 -E 3 /scratch/jakutagawa/RNA-seq/tumor_bams/reindex/hg19_5k_150bpOL_seg.txt.2 | /scratch/amak/packages/VarDictJava/VarDict/teststrandbias.R | /scratch/amak/packages/VarDictJava/VarDict/var2vcf_valid.pl -N PCAWG.ba92c434-3604-4b85-bc76-3bbe5c44253f.TopHat2.v1.chr.sorted -E -f 0.01 > /scratch/amak/varCalls/VarDictJava/c1b68b54-0258-470b-b6e2-b3f558bb1293/PCAWG.ba92c434-3604-4b85-bc76-3bbe5c44253f.TopHat2.v1.chr.sorted.2.vcf &


