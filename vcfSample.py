import sys, argparse
from argparse import RawTextHelpFormatter

__author__ = "Ryan Smith (ryanpsmith@wustl.edu)"
__version__ = "$Revision: 0.1.0 $"
__date__ = "$Date: 2015-2-9 $"

def get_args():
    parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter, description="\
fix_segs\n\
author: " + __author__ + "\n\
version: " + __version__ + "\n\
description: Extract samples from a gVCF file.")
    parser.add_argument('-i', '--input', type=argparse.FileType('r'), required=False, default=None, help="Input VCF file [stdin]")
    parser.add_argument('-o', '--output', type=argparse.FileType('w'), required=False, default=sys.stdout, help="Output file [stdout]")
    parser.add_argument('-s', '--samples', type=str, nargs='+', required=True, help="List of samples to extract GTs from (space delimited)")

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

def read_vcf(vcf_file):
    in_header = True
    header = []
    rows = []
    samples = None
    # read input VCF
    for line in vcf_file:
        if in_header:
            if line.startswith('#'):
                header.append(line)
                if line.startswith('#C'):
                    #samples are rows 10:end
                    samples = line.rstrip().split('\t')[9:]
                continue

            else:
                in_header = False

        rows.append(line.rstrip().split('\t'))

    return header, samples, rows

def extract_gts(vcf_file, sample_list, output):
    header, vcf_samples, variants = read_vcf(vcf_file)
    sample_header = header.pop().rstrip().split('\t')
    sample_columns = []
    for sample in sample_list:
        if sample not in vcf_samples:
            sys.stderr.write("Error: sample {0} not present\n".format(sample))
            sys.stderr.write("Samples in vcf:"+",".join(vcf_samples))
            exit(1)
        else:
            sample_columns.append(sample_header.index(sample))

    #write header lines
    for line in header:
        output.write(line)
    #write sample header
    output.write('\t'.join(sample_header[:9])+'\t'+'\t'.join(sample_list)+'\n')
    for var in variants:
        output.write('\t'.join(var[:9])+'\t'+'\t'.join([var[x] for x in sample_columns])+'\n')


def main():
    args = get_args()
    extract_gts(args.input, args.samples, args.output)
    
if __name__ == '__main__':
    main()