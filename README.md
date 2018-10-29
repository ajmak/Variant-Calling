# RNA Variant-Calling
## Pipelines/Wrappers for evaluating the performance of variant callers on RNA-Seq data

## Dependencies:
*Platypus
*Opossum
*VarDict
*Mutect2
*SplitNCigarReads
*Samtools
*R
*Python3


### Execution Scripts
Wrappers for executing Platypus, VarDict, and Mutect2 with any necessary preprocessing steps.
*platypus.sh
*mutect2.sh
*execute-vardict.sh

### Analysis 
post-process-wrap.sh collects necessary data files and calls compareWhitelist.R to run filtering and sensitivity calculations and produces summary files and figures for each tool. These summary files are then handed to makeCompiled.R to create comparison summary statistics and figures for sensitivity by expression, FPKM, and variant type.
