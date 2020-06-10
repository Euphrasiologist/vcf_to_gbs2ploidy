# Turn VCF to file compatible for the R package gbs2ploidy

This mini pipeline depends on vcftools, and therefore does not operate on the VCF directly. Two scripts are supplied, the first a command line R script which requires the packages `data.table` and `argparse`. The second is a convenience bash script *which isn't tested!*. So use with caution.

