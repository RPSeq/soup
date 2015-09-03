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

'''WARNING: THIS RUNS ONLY ON BEDTOOLS INTERSECT WITH FILTERED COLUMNS
Essentially a one-time use script.
Command used:
<(bedtools intersect -wa -wb -a <(bedtools slop -b 50 -g hg19.genome \
    -i <(vawk '{$3 = $2+1; print$0}' CEPH_MERGED_CIs_sparse.vcf | cut -f 1,2,3,5,10-12)) \
    -b <(vawk '{$3 = $2+1; print$0}' merged_1kg_CEPH_MEs.vcf | cut -f 1,2,3,5,10-12) | \
    grep -v "^X" | cut -f4-7,11-14 | sed 's/LINE1/L1/g')
'''

def compare(infile):
    entries = [line.rstrip().split('\t') for line in infile]
    #0 == Mobster MEI type
    #1-3 ==  Mobster GTs
    #4 == 1kg MEI type
    #5-7 == 1kg GTs
    callset = []
    for entry in entries:
        gt = GT(entry)
        #only append interescted MEIs of the same type.
        if gt.type_match:
            callset.append(GT(entry))

    #here's some bad hardcoded stuff. gets 'er done though
    #if i ever need to do this on more samples, this will be a pain to change.
    

    #lets initialize a shitload of lists to hardcoded 0s. this is probably the worst code i've ever written.
    #should use a single counter object or dict/hash but fuck it. cowboy coding day
    #count list format: [NA12878, NA12889, NA12890]

    sample_index = [NA12878, NA12889, NA12890]

    #total counts   
    het_count = [0,0,0]
    hom_alt_count = [0,0,0]
    hom_ref_count = [0,0,0]

    #match counts
    het_match = [0,0,0]
    hom_alt_match = [0,0,0]
    hom_ref_match = [0,0,0]

    #all possible mismatch types to be counted. 
    #this way I can tell how MobTyper is biased relative to the 1kg phase3 callset.
    het_VS_hom_alt = [0,0,0]
    het_VS_hom_ref = [0,0,0]

    hom_alt_VS_het = [0,0,0]
    hom_alt_VS_hom_ref = [0,0,0]

    hom_ref_VS_het = [0,0,0]
    hom_ref_VS_hom_alt = [0,0,0]


    #yay more terrible code. so many redundant comparisons. <33% efficient but hey, it'll work.
    for call in callset:
        for i in range(len(sample_index))
            #increment total counts for each GT type
            if call.mob_gts[i] == "0/1":
                het_count[i] += 1
            elif call.mob_gts[i] == "1/1":
                hom_alt_count[i] += 1
            elif call.mob_gts[i] == "0/0":
                hom_ref_count[i] += 1
            #get match counts for each GT type
            if call.mob_gts[i] == call.mob_gts[i]:
                if call.mob_gts[i] == "0/1":
                    het_match[i] += 1
                elif call.mob_gts[i] == "1/1":
                    hom_alt_match[i] += 1
                elif call.mob_gts[i] == "0/0":
                    hom_ref_match[i] += 1

            #if mismatch, determine the type of mismatch
            else:
                if call.mob_gts[i] == "0/1":
                    if call.kg_gts[i] == "0/0":
                        het_VS_hom_ref[i]+=1
                    elif call.kg_gts[i] == "1/1":
                        het_VS_hom_alt[i]+=1

                elif call.mob_gts[i] == "1/1":
                    if call.kg_gts[i] == "0/0":
                        hom_alt_VS_hom_ref[i]+=1
                    elif call.kg_gts[i] == "0/1":
                        hom_alt_VS_het[i]+=1

                elif call.mob_gts[i] == "0/0":
                    if call.kg_gts[i] == "1/1":
                        hom_ref_VS_hom_alt[i]+=1
                    elif call.kg_gts[i] == "0/1":
                        hom_ref_VS_het[i]+=1

    #now we've calculated all the fine-grain counts. 
    #need to calculate aggregate numbers and
    #present results in a format that will facilitate downstream R plotting.
    #really ryan, using enumerate? huh.
    for i, sample in enumerate(sample_index):





#test
class GT(object):
    def __init__(self, entry):
        self.type_match = False
        self.mob_type = entry[0]
        self.kg_type = entry[4]
        self.mob_gts = entry[1:4]
        self.count = len(self.mob_gts)

        #these are the 1KG GTs, which are phased and need to be converted to normal GT calls
        for i in range(5,8):
            if entry[i] == "0|0":
                entry[i] = "0/0"
            elif entry[i] == "1|1":
                entry[i] = "1/1"
            elif entry[i] == "1|0" or entry[i] == "0|1":
                entry[i] = "0/1"

        self.kg_gts = entry[5:8]

        if self.mob_type ==  self.kg_type:
            self.type_match = True


def main():
    args = get_args()
    compare(args.input)

    
if __name__ == '__main__':
    main()