#!/bin/bash

###################################################################
#Author: Ryan P Smith (ryanpsmith@genome.wustl.edu ryan.smith.p@gmail.com)
#Version: 0.0.1 (first ever)
#Date: 2015-10-2
#Purpose: Simple wrapper for bombing the lsf cluster with flash.sh jobs
###################################################################

#INPUT FILE DIRS
FASTQ=/gscmnt/gc2802/halllab/rsmith/Hippocampal_L1/data/FASTQ
SINGLE_IN=${FASTQ}/single
BULK_IN=${FASTQ}/bulk

#OUTPUT DIRS
#BAM=/gscmnt/gc2802/halllab/rsmith/Hippocampal_L1/data/BAM
#test dir
BAM=/gscmnt/gc2802/halllab/rsmith/Hippocampal_L1/data/BAM/TESTMOB
BULK_OUT=${BAM}/bulk
SINGLE_OUT=${BAM}/single

#project src directory
SRC=/gscmnt/gc2802/halllab/rsmith/Hippocampal_L1/src

#make sure job group is set to reasonable number (i have brought the cluster to a grinding halt before)
bgmod -L 40 /rsmith/flash

################################################
###bulk
################################################


INPUT=$BULK_IN
BAM_DIR=$BULK_OUT
#all bulk samples
SAMPLES=`ls $INPUT | sed -e 's/.s_1_._sequence.txt.gz//g' | uniq`
#SAMPLES=("Hippocampus.Bulk.CTRL-36")
for SAMPLE in $SAMPLES; do
    # set sample specific variables
    #   input fastq.gz files:
    FQ1=${INPUT}/${SAMPLE}.s_1_1_sequence.txt.gz;
    FQ2=${INPUT}/${SAMPLE}.s_1_2_sequence.txt.gz;
    # output dir:
    OUTPUT=${BAM_DIR}/${SAMPLE}
    # logs dir:
    LOGS=${BAM_DIR}/${SAMPLE}/logs

    if [ ! -d $LOGS ]
    then
        mkdir -p $LOGS
    fi

    bomb -t 8 -m 10 -J $SAMPLE -g /rsmith/flash -q long \
     -o ${LOGS}/${SAMPLE}.out -e ${LOGS}/${SAMPLE}.err \
    "bash ${SRC}/flash.sh -d $OUTPUT -l $LOGS -s $SAMPLE $FQ1 $FQ2"
done

################################################
###single
################################################

#test on one small single sample
# INPUT=$SINGLE_IN
# BAM_DIR=$SINGLE_OUT

# # test on smallest sample
# #SAMPLES=("Cortex.Single.WGS.CTRL-45.Neuron-#4")

# # all single cell samples
# SAMPLES=`ls $INPUT | sed -e 's/.s_1_._sequence.txt.gz//g' | uniq`
# for SAMPLE in $SAMPLES; do
#     # set sample specific variables
#     #   input fastq.gz files:
#     FQ1=${INPUT}/${SAMPLE}.s_1_1_sequence.txt.gz;
#     FQ2=${INPUT}/${SAMPLE}.s_1_2_sequence.txt.gz;
#     #   output dir:
#     OUTPUT=${BAM_DIR}/${SAMPLE}
#     #   logs dir:
#     LOGS=${BAM_DIR}/${SAMPLE}/logs

#     if [ ! -d $LOGS ]
#     then
#         mkdir -p $LOGS
#     fi

#     bomb -t 8 -m 16 -J $SAMPLE -g /rsmith/flash -q long \
#      -o ${LOGS}/${SAMPLE}.out -e ${LOGS}/${SAMPLE}.err \
#     "bash ${SRC}/flash.sh -t -d $OUTPUT -l $LOGS -s $SAMPLE $FQ1 $FQ2"
# done
