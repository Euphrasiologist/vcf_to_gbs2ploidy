#!/usr/bin/env Rscript

library(argparse)
library(data.table)
# create parser object
parser <- ArgumentParser(description = "Generate a matrix of heterozygous allele pairs. By default, any sites with more than two alleles are removed.")
parser$add_argument("file", 
    help="Path to file from output of vcftools --extract-FORMAT-info AD")
parser$add_argument("--start", type="integer", 
    help="First numeric column, default = 2",
    metavar="number", default = 2)

args <- parser$parse_args()

# read data.
table <- fread(args$file, header = TRUE)

# main function takes the output of the vcftools --gzvcf ../Euphrasia_gbs_110220_fSNPs_fInds.recode.vcf.gz --extract-FORMAT-info AD
# for use later in the gbs2ploidy pipeline.

format_AD <- function(table, start = 2){
  setDT(table)
  # remove first two columns
  subs <- -c(1:start)
  subtab <- table[,..subs]
  # remove any sites whta have more than two alleles..? Count the commas
  logmat <- apply(X = subtab, MARGIN = 1, FUN = function(x){
    nchar(as.character(x)) - nchar( gsub(pattern = ",", replacement = "", x = x, fixed = TRUE)) > 1
  })
  # boolean vector the length of the nrow(data)
  subtab <- subtab[!apply(logmat, 2, function(x) any(x == TRUE)),]

  # get the names of all of the columns
  coln <- colnames(subtab)
  # loop through samples
  for(name in coln){
    subtab[, c(name, paste0(name, ".1")) := tstrsplit(as.character(get(name)), ",", fixed = TRUE)]
  }
  # order columns
  vars <- coln[!grepl(coln, pattern = ".1", fixed = TRUE)]
  vis <- c("", ".1")
  colorder <- as.vector(outer(vars, vis, paste0))[order(as.vector(outer(vars, vis, paste0)))]
  # set the order here.
  setcolorder(subtab, colorder)

  # now just need to replace pairs that have a zero with NA
  # data table function to replace all NA's with zeroes.
  replNA <-  function(DT) {
      for (i in names(DT))
      DT[is.na(get(i)), (i) := 0]
    }

  # change all NA's to zero
  replNA(subtab)
  
  # loop through pairs of columns
  # in each list is a pair of columns to compare
  # if a zero is found in one of the pairs, replace
  # with NA's, else, print x
  lis <- list()
  for(i in seq(1, ncol(subtab), 2)){
    j <- i + 1
    lis[[i]] <- t(apply(subtab[,i:j], 1, function(x){
      i<-match(0,x)
      if(!is.na(i)){
        c(NA,NA)
        } else(x) 
      }))
  }
  finmat <- do.call("cbind", lis)
  finmat <- apply(finmat, 2, as.numeric)
  
  fwrite(x = finmat, file = "", sep = "\t", na = NA, col.names = FALSE)
}

format_AD(table, args$start)