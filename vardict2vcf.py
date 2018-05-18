"""Takes a vardict output file and outputs it in VCF format """
import sys
import os


def parseVar(varInput, vcf):
    i=0
    for line in open(varInput, 'r'):
        each = line.rstrip().split()
        sample = each[0].split()[0]
        chrm = each[1]
        start = each[3]
        end = each[4]
        refAllele = each[5]
        altAllele = each[6]
        qual = each[18]
        ID = ''
        info = each[33]
        

        vcf.write('{0} \t {1} \t {2} \t {3} \t {4} \t {5} \t {6} \n'.format(chrm, start, ID, refAllele, altAllele, 'None',  info))
        i+=1
var = sys.argv[1]
vcf = open(var + '.vcf', 'w+')
#vcf = open(var.split('/')[-1] + '.vcf', 'w+')
print(str(vcf))
maf = parseVar(var, vcf)

vcf.close()