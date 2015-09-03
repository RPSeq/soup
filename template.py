import sys, argparse
from argparse import RawTextHelpFormatter

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

def main():
    args = get_args()
    
if __name__ == '__main__':
    main()