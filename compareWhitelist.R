#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)


args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("Supply working directory, whitelist, tumor, normal VCFs, and .n", call.=FALSE)
}


setwd(args[1])

whitelist=read.table(args[2], sep='\t', header=FALSE, stringsAsFactors=FALSE)
tumorVCF=read.table(args[3], sep='\t', header=FALSE, stringsAsFactors=FALSE)
normalVCF=read.table(args[4], sep='\t', header=FALSE, stringsAsFactors=FALSE)
rnaEdit=read.table(args[5], sep='\t', header=TRUE, stringsAsFactors=FALSE)
doFPKM=read.table(args[6], sep='\t', header=FALSE, stringsAsFactors=FALSE)



dim(whitelist)

########################## Filter out normals ########################## 

colnames(tumorVCF) <- c("Chr", "Start", "ID", "Ref", "Alt", "Quality", "Filter", "Variant")
colnames(normalVCF) <- c("Chr", "Start", "ID", "Ref", "Alt", "Quality", "Filter", "Variant")

#Filter out incomplete lines
tumorVCF$Start <- as.numeric(tumorVCF$Start)
normalVCF$Start <- as.numeric(normalVCF$Start)
normalVCF <- normalVCF %>% filter(!is.na(normalVCF$Start))
tumorVCF <- tumorVCF %>% filter(!is.na(tumorVCF$Start))

#
somatic <- tumorVCF %>% anti_join(normalVCF, by="Start")
numFiltGermline <- dim(normal)[1] - dim(somatic)[1]


########################## Filter out RNA editing sites ##########################
rnaEdit$position <- as.numeric(rnaEdit$position)
somaticMinusEdits <- somatic %>% anti_join(rnaEdit, by=c("Chr" = "chromosome", "Start" = "position") )
numFiltEdits <- dim(somatic)[1] - dim(somaticMinusEdits)[1]

########################## Filter out low mapQ scores ##########################
somaticMQ50 <- filter(somaticMinusEdits, somaticMinusEdits$Quality >= 30)
numFiltMQ50 <- dim(somaticMinusEdits)[1] - dim(somaticMQ50)[1]

########################## Compare to whitelist MAF ##########################
# V3 is start position, V6 variant location, V7 variant type (SNP), V17 is probably VAF?, V42 cancer

foundInMaf <- somaticMinusEdits %>% semi_join(whitelist, by=c("V2"="Chr", "V3"="Start"))
correctClass <- somaticMinusEdits %>% semi_join(whitelist, by=c("V2"="Chr", "V3"="Start", "V7"="Variant"))

totalMaf <- dim(whitelist)[1]
numInMaf <- dim(foundInMaf)[1]
sensitivity <- numInMaf / (numInMaf + totalMaf)


numCorrectClass <- dim(correctClass)[1]



Maflocs <- whitelist %>% semi_join(somaticMinusEdits, by=c("Chr"="V2", "Start_position"="V3"))




########################## Compare FPKM ##########################

colnames(doFPKM) <- c("Ensembl", "GeneID", "FPKM")
doFPKM <- doFPKM[-1,]

#mafLocsExp <- DO38901 %>% semi_join(Maflocs, by=c("genes"="Hugo_Symbol"))
#filt.DO38 <- DO38901 %>% filter(DO38901, DO38901 > 1)
#filtMafExp <- filt.DO38 %>% semi_join(whiteMaf, by=c("genes"="Hugo_Symbol"))
#filtMaf <- whiteMaf %>% semi_join(filt.DO38, by=c("Hugo_Symbol"="genes"))

#filtMaf %>% group_by(Variant_Classification) %>% summarize(count=n())