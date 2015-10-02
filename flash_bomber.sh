#!/bin/bash

###################################################################
#Author: Ryan P Smith (ryanpsmith@genome.wustl.edu ryan.smith.p@gmail.com)
#Version: 0.0.1 (first ever)
#Date: 2015-10-2
#Purpose: Simple wrapper for bombing the lsf cluster with flash.sh jobs
###################################################################

#INPUT FILE DIRS
INPUT=/gscmnt/gc2802/halllab/rsmith/Hippocampal_L1/FASTQ/original
SINGLE_IN=${INPUT}/single

#OUTPUT DIRS
OUTPUT_DIR=/gscmnt/gc2802/halllab/rsmith/Hippocampal_L1/FASTQ/flash
BULK_OUT=${OUTPUT_DIR}/bulk
SINGLE_OUT=${OUTPUT_DIR}/single

#LOG DIRS
BULK_LOGS=${OUTPUT_DIR}/bulk_logs
SINGLE_LOGS=${OUTPUT_DIR}/single_logs

#project src directory
SRC=/gscmnt/gc2802/halllab/rsmith/Hippocampal_L1/src

#make sure job group is set to reasonable number (i have brought the cluster to a grinding halt before)
bgmod -L 30 /rsmith/flash

#test on one small single sample
SAMPLES=("Cortex.Single.WGS.CTRL-45.Neuron-#4")

for SAMPLE in $SAMPLES; do
    FQ1=${SINGLE_IN}/${SAMPLE}.s_1_1_sequence.txt.gz;
    FQ2=${SINGLE_IN}/${SAMPLE}.s_1_2_sequence.txt.gz;
    bomb -t 8 -m 16 -J $SAMPLE -g /rsmith/flash -q long -o ${SINGLE_LOGS}/${SAMPLE}.out -e ${SINGLE_LOGS}/${SAMPLE}.err \
    "bash ${SRC}/flash.sh -d ${SINGLE_OUT} -s $SAMPLE $FQ1 $FQ2"
done



