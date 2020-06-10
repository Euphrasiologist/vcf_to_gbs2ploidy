#!/usr/bin/env bash

# if no arguments
if [[ -z $1 ]]; then
    printf "Error. No arguments supplied.\nUsage: vcf_to_gbs2ploidy.sh [vcf OR vcf.gz]\n"
    exit 1
fi

# Check the version of the VCF file itself
# check for .gz file ending
match_gz="\\.gz$"

if [[ $1 =~ $match_gz ]]; then
    # check that the VCF is the correct format. If there is a match, 1 should return.
    CHECKVCFGZ=$(zcat $1 | head -1 | grep -ohc "##fileformat=VCF")
    if [[ $CHECKVCFGZ =~ "0" ]]; then
        printf "Incorrect VCF format, please check the VCF is not corrupt.\n"
        exit 1
    fi    
    # the argument for later
    VCFARG="--gzvcf"

elif ! [[ $1 =~ $match_gz ]]; then
    # check that the VCF is the correct format. If there is a match, 1 should return.
    CHECKVCFGZ=$(cat $1 | head -1 | grep -ohc "##fileformat=VCF")
    if [[ $CHECKVCFGZ =~ "0" ]]; then
        printf "Incorrect VCF format, please check the VCF is not corrupt.\n"
        exit 1
    fi    
    # the argument for later
    VCFARG="--vcf"
fi

# invoke vcftools (http://vcftools.sourceforge.net/)

vcftools $VCFARG $1 --extract-FORMAT-info AD -c > ./temp_AD.txt

# then the R script

Rscript format_AD.R ./temp_AD.txt
