import sys, argparse
from argparse import RawTextHelpFormatter

#grab specific include from mobtyper dir (this is a bad line of code)
sys.path.append('/gscmnt/gc2719/halllab/users/rsmith/git/mobtyper')
from MobTyper import Variant, Mob_Sample, Vcf, Library

__author__ = "Ryan Smith (ryanpsmith@wustl.edu)"
__version__ = "$Revision: 0.1.0 $"
__date__ = "$Date: 2015-3-9 $"

def get_args():
    parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter, description="\
fix_segs\n\
author: " + __author__ + "\n\
version: " + __version__ + "\n\
description: DESCRIPTION")
    parser.add_argument('-i', '--input', type=argparse.FileType('r'), required=False, default=None, help="Input file [stdin]")
    parser.add_argument('-o', '--output', type=argparse.FileType('w'), required=False, default=sys.stdout, help="Output file [stdout]")

    # parse the arguments
    args = parser.parse_args()

    # if no input, check if part of pipe and if so, read stdin.
    if args.input == None:
        if sys.stdin.isatty():
            parser.print_help()
            exit(1)
        else:
            args.input = sys.stdin
    # send back the user input
    return args

def count_calls(infile,outfile):
    vcf, variants = read_vcf(infile)
    sample_counts = {}
    for sample in vcf.sample_list:
        sample_counts[sample] = 0
    for var in variants:
        for sample in vcf.sample_list:
            if var.gts[sample].format['GT'] == "1/1" or var.gts[sample].format['GT'] == "0/1":
                sample_counts[sample]+=1
    for sample in vcf.sample_list:
        outfile.write("{0}\t{1}\n".format(sample, sample_counts[sample]))


def read_vcf(vcf_in):
    in_header = True
    header = []
    mob_vcf = Vcf()
    variants = []

    # read input VCF
    for line in vcf_in:
        if in_header:
            if line[0] == '#':
                header.append(line)
                continue
            else:
                in_header = False
                mob_vcf.add_header(header)

        v = line.rstrip().split('\t')
        var = Variant(v, mob_vcf)
        variants.append(var)

    vcf_in.close()
    return mob_vcf, variants

def main():
    args = get_args()
    count_calls(args.input, args.output)
    
if __name__ == '__main__':
    main()