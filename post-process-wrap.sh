#!/bin/bash
#$ -cwd


whitelist="/pod/pstore/groups/brookslab/amak/var-prediction-testing/ref-features/October_2016_whitelist_2583.snv_mnv_indel.maf"
#whitelist="/pod/pstore/groups/brookslab/amak/var-prediction-testing/download-lists/second-download-set-tcga/new_whitelist.maf"
#URLlist="/pod/pstore/groups/brookslab/amak/var-prediction-testing/download-lists/wgs-match-RNAseq-tumor-normal-refList-head.tsv"
URLlist="/pod/pstore/groups/brookslab/csoulette/projects/PCAWG/metadata/release_may2016.v1.4.tsv"
metadata="/pod/pstore/groups/brookslab/amak/var-prediction-testing/download-lists/second-download-set-tcga/metadata.cart.2018-05-29.json"
pcawgIDs="/pod/pstore/groups/brookslab/amak/var-prediction-testing/download-lists/second-download-set-tcga/pcawgIDs.tsv"
tophatExp="/pod/pstore/groups/brookslab/amak/var-prediction-testing/expression/star_tophat_fpkm_geneID.donor.log"
parentdir="/scratch/amak/varCalls/Mutect/"
#parentdir="/scratch/amak/varCalls/VarDict/round-one-results/sample1"
varOut="/scratch/amak/varCalls/VarDict/round-one-results/sample1"
platOut="/scratch/amak/varCalls/Platypus/tumor-vcfs/"
mutOut="/scratch/amak/varCalls/Mutect/tumor-vcfs/"
hapOut=""
rnaEdit="/pod/pstore/groups/brookslab/amak/var-prediction-testing/ref-features/Human_AG_rnaeditsites_hg19_v2.txt"

#For all VarDict VCFs --> will find all corresponding VCFs from other tools
for vcf in $(find $parentdir -name '*.vcf'); do
    echo 
    echo 
    uid=$(basename $vcf)
    IFS='_.'; set $uid; uid=$(echo $1) 
    IFS=''

#    echo $uid
    # Grab the case ID from the metadata file and use it to find the match normal file name. Use the case IDs to find the line from the URL list containing the Donor ID and match-normal ID
    caseID=$(grep -A 10 $uid $metadata | grep case_id)

    IFS=':'; set $caseID; caseID=$(echo $2 | sed 's/", //g' | sed 's/ "//g')
    IFS=''
    echo 'Case ID: ' $caseID
    # Grab filename for match normal
    normalID=$(grep -B 10 $caseID $metadata | grep submitter_id | grep -v $uid)  
    IFS=':'; set $normalID; normalID=$(echo $2 | sed 's/", //g' | sed 's/ "//g')
    echo "NORMAL ID:" $normalID

    donorLine=$(grep $caseID $URLlist)
#    echo $donorLine



    #Grab Donor ID

    donorID=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $5}')
    echo 'Donor ID: ' $donorID

    ## Helber code for making a donor-list for filtering ##
"""
    if grep -q $donorID '/pod/pstore/groups/brookslab/amak/scripts/Variant-Calling/donor-list.txt'; then
	continue
    else
	echo $donorID >> 'donor-list.txt'
    fi
"""
    #Write whitelist MAF to temporary file 
#    donorMaf=$parentdir'/'$donorID'.maf'
    #Once I have the set of BAMs we're working with, subset so this is faster
    time grep $donorID $whitelist > $parentdir'/'$donorID'.maf'


    #Grab expression data for Donor
    time awk -v col=$donorID 'NR==1{for(i=1;i<=NF;i++){if($i==col){c=i;break}} print $c} NR>1{print $1, "\t", $2, "\t", $c}' $tophatExp > $parentdir'/'$donorID'.fpkm'
#    echo $FPKM
    #Grab Match Normal
    STARNormal=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $73}')
    STARTumor=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $87}')
    tophatNormal=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $77}')
    tophatTumor=$(echo $donorLine | awk 'BEGIN {FS="\t"}; {print $91}')
    echo $tophatNormal
    IFS=.
    set $STARNormal
    normal=$(echo $2 | sed 's/", //g' | sed 's/ "//g')   
    set $STARTumor
    tumor=$(echo $2 | sed 's/", //g' | sed 's/ "//g')
    echo 'tumor' $tumor
    unset IFS
#    findStar='*'$STARNormal'*'
    varVCFN=$(find $varOut -mindepth 1 -name "*${normal}*.vcf")
    varVCFT=$(find $varOut -mindepth 1 -name "*${tumor}*.vcf")

    mutVCFN=$(find $mutOut -mindepth 1 -name "*${normalID}*.vcf")
    mutVCFT=$(find $mutOut -mindepth 1 -name "*${tumor}*.vcf")
    echo 
    echo 'vcf tumor: ' $mutVCFT
    echo 'vcf normal: ' $mutVCFN
    echo 'donor MAF: ' $donorMaf

#    platVCFN=$(find $platOut -name '*'$STARNormal'*')
#    platVCFT=$(find $platOut -name '*'$STARTumor'*')
#    mutVCFN=$(find $mutOut -name '*'$STARNormal'*')
#    mutVCFT=$(find $mutOut -name '*'$STARTumor'*')
#    hapVCFN=$(find $hapOut -name '*'$STARNormal'*')
#    hapVCFT=$(find $hapOut -name '*'$STARTumor'*')
     
    echo 'donor id ' $donorID
    echo 'UID ' $uid

    echo 'tophat Normal: ' $tophatNormal
    
    echo 'star tumor: ' $STARTumor
    echo  'star normal: ' $STARNormal

    #Supply files and paths to R for filtering and comparing to whitelist MAF file

#    Rscript compareWhitelist.R $parentdir $parentdir'/'$donorID'.maf' $varVCFT $varVCFN $rnaEdit


# rm donorMaf

done
