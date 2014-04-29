#!/usr/bin/bash

###############################################################################
# about
###############################################################################

#
# I received a bunch of .pdf files with scanned documents from where I needed 
# to extract texts using OCR. 
#
# This bash script is an automated solution making use of xpdf and tesseract-ocr
#
# Requirements:
# - The script is linux based although only tested on Ubuntu 13.10
# - Before you proceed be sure you have installed: 
#
# ~ sudo apt-get install tesseract-ocr tesseract-ocr-eng tesseract-ocr-nld 
# xpdf imagemagick poppler-utils
#
# How to use:
# - copy this script to the directory where you have stored your .pdf
# - check the language of the .pdf file 
# - (SUPPORTED_LANG currently set to eng | nld)
# - run the script like: bash pdf_to_txt.bash myfile.pdf eng
#
# What does it do:
# - check SUPPORTED_LANG parameter
# - copy .pdf to process to TMP_DIR
# - extract every page to a .ppm file
# - convert the .ppm file to a .ttf file
# - put the .ttf file through tesseract using the desired LANG
# - collect the texts and output them .....
#
# $0 = SCRIPT_NAME
# $1 = PDF_FILE
# $2 = LANG 
#

###############################################################################
# variables
###############################################################################

SCRIPT_NAME=`basename "$0" .sh`
TMP_DIR=${SCRIPT_NAME}-tmp
OUTPUT_FILE=${SCRIPT_NAME}-output.txt
SUPPORTED_LANG=(eng nld)
 
###############################################################################
# parameter checking
###############################################################################

MATCH=$(echo "${SUPPORTED_LANG[@]:0}" | grep -o $2)  

if [ ! -z $MATCH ]; then
    echo "we have support for $2"
else
    echo "$2 is not supported"
    exit 0;
fi   

###############################################################################
# program
###############################################################################

mkdir $TMP_DIR
cp $1 $TMP_DIR
cd $TMP_DIR

pdftoppm -r 600 * ocrbook

for i in *.ppm
do
  BASE=`basename "$i" .ppm`
  convert "$i" "${BASE}.tif"
  tesseract "${BASE}.tif" "${BASE}" -l $2
  cat ${BASE}.txt | tee -a $OUTPUT_FILE
  echo "[pagebreak]" | tee -a $OUTPUT_FILE
  rm ${BASE}.*
done

mv $OUTPUT_FILE ..
rm *
cd ..
rmdir $TMP_DIR

#
# EOF
#