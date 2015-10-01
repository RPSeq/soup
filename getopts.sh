#!/bin/bash

####################################################
#Based on http://tuxtweaks.com/2014/05/bash-getopts/
#by Linerd
#Author: Ryan P Smith (ryanpsmith@wustl.edu ryanpsmith@genome.wustl.edu ryan.smith.p@gmail.com)
####################################################


#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Initialize variables to default values.
OPT_A=A
OPT_B=B
OPT_C=C
OPT_D=D

#Help function
function HELP {
  echo -e \\n"Help documentation for ${SCRIPT}"\\n
  exit 1
}

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
#echo -e \\n"Number of arguments: $NUMARGS"
if [ $NUMARGS -eq 0 ]; then
  HELP
fi

### Start getopts code ###

#Parse command line flags
#If an option should be followed by an argument, it should be followed by a ":".
#Notice there is no ":" after "h". The leading ":" suppresses error messages from
#getopts. This is required to get my unrecognized option code to work.

while getopts :a:b:c:d:h FLAG; do
  case $FLAG in
    a)  #set option "a"
      OPT_A=$OPTARG
      echo "-a used: $OPTARG"
      echo "OPT_A = $OPT_A"
      ;;
    b)  #set option "b"
      OPT_B=$OPTARG
      echo "-b used: $OPTARG"
      echo "OPT_B = $OPT_B"
      ;;
    c)  #set option "c"
      OPT_C=$OPTARG
      echo "-c used: $OPTARG"
      echo "OPT_C = $OPT_C"
      ;;
    d)  #set option "d"
      OPT_D=$OPTARG
      echo "-d used: $OPTARG"
      echo "OPT_D = $OPT_D"
      ;;
    h)  #show help
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -$OPTARG not allowed."
      HELP
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.
# Now we are looking at the first arg after the getopts (-arg) flags

### End getopts code ###


### Main loop to process files ###

#This is where your main file processing will take place. This example is just
#printing the files and extensions to the terminal. You should place any other
#file processing tasks within the while-do loop.
#while there are still args remaining (after the getopts switches.)
while [ $# -ne 0 ]; do
  FILE=$1
  TEMPFILE=`basename $FILE`
  FILE_BASE=`echo "${TEMPFILE%.*}"`  #file without extension
  FILE_EXT="${TEMPFILE##*.}"  #file extension


  echo -e \\n"Input file is: $FILE"
  echo "File withouth extension is: $FILE_BASE"
  echo -e "File extension is: $FILE_EXT"\\n
  shift  #Move on to next input file.
done

### End main loop ###

exit 0