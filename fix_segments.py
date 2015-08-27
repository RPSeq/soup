import sys, argparse
from argparse import RawTextHelpFormatter

__author__ = "Ryan Smith (ryanpsmith@wustl.edu)"
__version__ = "$Revision: 0.1.0 $"
__date__ = "$Date: 2015-25-8 $"

def get_args():
    parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter, description="\
fix_segs\n\
author: " + __author__ + "\n\
version: " + __version__ + "\n\
description: Fix norm.short CNV segment files (ensure consective segments are continuous")
    parser.add_argument('-i', '--input', type=argparse.FileType('r'), required=False, default=None, help="Input norm.short file [stdin]")
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

def read_short(shortfile):
    rows = []
    for entry in shortfile:
        items = entry.strip().split("\t")
        if len(items) != 14:
            sys.stderr.write("Error: incorrect number of columns in short file.")
            exit(1)
        rows.append(items)
    return rows

def fix_short(short_rows, output):
    #chrom = row[2]
    #start = row[3]
    #stop = row[4]
    prev_row = False
    for row in short_rows:
        if not prev_row:
            prev_row = row
            continue      
        elif prev_row[2] == row[2]:
            prev_row[4] = row[3]
        prev_row = row
    for row in short_rows:
        output.write("\t".join(row)+"\n")
    return

def main():
    args = get_args()
    short = read_short(args.input)
    fix_short(short, args.output)
    return


if __name__ == '__main__':
    main()