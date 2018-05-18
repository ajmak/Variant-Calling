#!/usr/bin/env Rscript


args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("Supply working directory, whitelist, tumor, and normal VCFs.n", call.=FALSE)
}


setwd(args[1])

whitelist=read.table(args[2], sep='\t', header=TRUE, stringsAsFactors=FALSE)
tumorVCF=read.table(args[3], sep='\t', header=TRUE, stringsAsFactors=FALSE)
normalVCF=read.table(args[4], sep='\t', header=TRUE, stringsAsFactors=FALSE)

#print dim(whitelist, 4)