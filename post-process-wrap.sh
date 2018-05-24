#!/bin/bash
#$ -cwd


whitelist="/pod/pstore/groups/brookslab/amak/var-prediction-testing/ref-features/October_2016_whitelist_2583.snv_mnv_indel.maf"
URLlist="/pod/pstore/groups/brookslab/amak/var-prediction-testing/download-lists/wgs-match-RNAseq-tumor-normal-refList-head.tsv"
#"/pod/pstore/groups/brookslab/csoulette/projects/PCAWG/metadata/release_may2016.v1.4.tsv"


tophatExp="/pod/pstore/groups/brookslab/csoulette/projects/PCAWG/metadata/tophat_star_fpkm_uq.v2_aliquot_gl.donor.log"
parentdir="/scratch/amak/varCalls/VarDict/round-one-results/sample1"
varOut="/scratch/amak/varCalls/VarDict/round-one-results/sample1"
platOut="/scratch/amak/varCalls/Platypus/round-one-results/"
mutOut="/scratch/amak/varCalls/Mutect/round-one-results/"
hapOut=""

#For all VarDict VCFs --> will find all corresponding VCFs from other tools
for vcf in $(find $parentdir -name '*.vcf'); do
    uid=$(basename $vcf)
    IFS=.; set $uid; uid=$(echo $2)
    IFS=''

#    echo $uid
    # Grab the line from the URL list containing the Donor ID and match-normal ID
    donorLine=$(grep $uid $URLlist)
#    echo $donorLine
    #Grab Donor ID
    donorID=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $5}')

    #Write whitelist MAF to temporary file 
    donorMaf=$parentdir'/'$donorID'.maf'
    #Once I have the set of BAMs we're working with, subset so this is faster
    time grep $donorID $whitelist > $parentdir'/'$donorID'.maf'


    #Grab expression data for Donor
    awk -v col=$donorID 'NR==1{for(i=1;i<=NF;i++){if($i==col){c=i;break}} print $c} NR>1{print $1, "\t", $c}' $tophatExp > $parentdir'/'$donorID'.fpkm'
#    echo $FPKM
    #Grab Match Normal
    STARNormal=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $73}')
    STARTumor=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $87}')
    tophatNormal=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $77}')
    tophatTumor=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $91}')
    echo $tophatNormal
    IFS=.
    set $STARNormal
    normal=$(echo $2)   
    set $STARTumor
    tumor=$(echo $2)
    echo 'tumor' $tumor
    unset IFS
#    findStar='*'$STARNormal'*'
    varVCFN=$(find $varOut -mindepth 1 -name "*${normal}*.vcf")
    varVCFT=$(find $varOut -mindepth 1 -name "*${tumor}*.vcf")
    echo 
    echo $varVCFT
#    platVCFN=$(find $platOut -name '*'$STARNormal'*')
#    platVCFT=$(find $platOut -name '*'$STARTumor'*')
#    mutVCFN=$(find $mutOut -name '*'$STARNormal'*')
#    mutVCFT=$(find $mutOut -name '*'$STARTumor'*')
#    hapVCFN=$(find $hapOut -name '*'$STARNormal'*')
#    hapVCFT=$(find $hapOut -name '*'$STARTumor'*')
     
    echo $donorID
    echo $uid

    echo $tophatNormal
    
    echo $STARTumor
    echo $STARNormal

    #Supply files and paths to R for filtering and comparing to whitelist MAF file

#    Rscript compareWhitelist.R $parentdir $donorMaf $tophatTumor $tophatNormal 


# rm donorMaf
done
