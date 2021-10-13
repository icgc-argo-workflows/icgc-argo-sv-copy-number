#!/usr/bin/env Rscript

# run the facets library

# Version changelog:
# v2:
#  Sourcing runFacets_myplot.R from the same folder of this script, wherever that might be.
# v2.1:
#  Added '--tumorName' and '--normalName' options to account for different naming schemes.
#  Account for the possibility that '--cval2' and '--pre_cval' are passed with a string 'NULL'
# v3:
#  set seed
#  use a default pre_cval
#  use only one cval (remove cval2; cval1 -> cval)
#  increase cval by 50 if hyperfragmented (save as additional result files).
#  add max_segs to define hyperfragmentation.
# v3.icgc-argo:
#  remove normalName
#  no cval increase steps
#  omit runFacets_myplot.R and plotting only logR.

suppressPackageStartupMessages(library("optparse"));
suppressPackageStartupMessages(library("RColorBrewer"));
suppressPackageStartupMessages(library("plyr"));
suppressPackageStartupMessages(library("dplyr"));
suppressPackageStartupMessages(library("tidyr"));
suppressPackageStartupMessages(library("stringr"));
suppressPackageStartupMessages(library("magrittr"));
suppressPackageStartupMessages(library("facets"));
suppressPackageStartupMessages(library("foreach"));




if (!interactive()) {
    options(warn = -1, error = quote({ traceback(); q('no', status = 1) }))
}

optList <- list(
	make_option("--seed", default = 1234, type = 'integer', help = "seed for reproducibility"),
	make_option("--snp_nbhd", default = 250, type = 'integer', help = "window size"),
	make_option("--minNDepth", default = 5, type = 'integer', help = "minimum depth in normal to keep the position"),
	make_option("--maxNDepth", default= 500, type= 'integer', help = "maximum depth in normal to keep the position"),
	make_option("--pre_cval", default = 80, type = 'integer', help = "pre-processing critical value"),
	make_option("--cval", default = NULL, type = 'integer', help = "critical value for estimating diploid log Ratio"),
	make_option("--max_cval", default = 5000, type = 'integer', help = "maximum critical value for segmentation (increases by 100 until success)"),
	make_option("--min_nhet", default = 25, type = 'integer', help = "minimum number of heterozygote snps in a segment used for bivariate t-statistic during clustering of segment"),
	make_option("--genome", default = 'hg38', type = 'character', help = "genome of counts file"),
	make_option("--unmatched", default=FALSE, type=NULL,  help="is it unmatched?"),
	make_option("--minGC", default = 0, type = NULL, help = "min GC of position"),
	make_option("--maxGC", default = 1, type = NULL, help = "max GC of position"),
	make_option("--max_segs", default = 3000, type = 'integer', help = "max number of segments to avoid hyperfragmentation"),
	make_option("--outPrefix", default = NULL, help = "output prefix"),
	make_option("--tumorName", default = NULL, help = "tumorName")
)

parser <- OptionParser(usage = "%prog [options] [tumor-normal base counts file]", option_list = optList);

arguments <- parse_args(parser, positional_arguments = T);
opt <- arguments$options;

if (length(arguments$args) < 1) {
    cat("Need base counts file\n")
    print_help(parser);
    stop();
} else if (is.null(opt$outPrefix)) {
    cat("Need output prefix\n")
    print_help(parser);
    stop();
} else if (is.null(opt$tumorName)) {
    cat("Need tumorName\n")
    print_help(parser);
    stop();
} else {
    baseCountFile <- arguments$args[1];
}

# Print input file and the options
cat("\nInput file:\n",baseCountFile,"\n")
cat("\nOptions:\n")
for(i in 1:length(opt))
{
	cat("",names(opt[i]), "=", head(opt[[i]],1),"\n")
}
cat("\n")

switch(opt$genome,
	b37={gbuild="hg19"},
	b37_hbv_hcv={gbuild="hg19"},
	GRCh37={gbuild="hg19"},
	hg19={gbuild="hg19"},
	hg19_ionref={gbuild="hg19"},
	mm9={gbuild="mm9"},
	mm10={gbuild="mm10"},
	GRCm38={gbuild="mm10"},
	hg38={gbuild="hg38"},
       { stop(paste("Invalid Genome",opt$genome)) })

buildData=installed.packages()["facets",]
cat("#Module Info\n")
for(fi in c("Package","LibPath","Version","Built")){
    cat("#",paste(fi,":",sep=""),buildData[fi],"\n")
}
version=buildData["Version"]
cat("\n")

rcmat <- readSnpMatrix(gzfile(baseCountFile))
chromLevels=unique(rcmat[,1])
print(chromLevels)
if (gbuild %in% c("hg19", "hg18")) { chromLevels=intersect(chromLevels, c(1:22,"X"))
} else { chromLevels=intersect(chromLevels, c(1:19,"X"))}
print(chromLevels)

if(is.null(opt$cval)) { stop("cval cannot be NULL")}

set.seed(opt$seed)

if (opt$minGC == 0 & opt$maxGC == 1) {
	preOut=preProcSample(rcmat, snp.nbhd = opt$snp_nbhd, ndepth = opt$minNDepth, cval = opt$pre_cval, 
		gbuild=gbuild, ndepthmax=opt$maxNDepth, unmatched=opt$unmatched)
} else {
	if (gbuild %in% c("hg19", "hg18", "hg38"))
		nX <- 23
	if (gbuild %in% c("mm9", "mm10"))
	 nX <- 20
	pmat <- facets:::procSnps(rcmat, ndepth=opt$minNDepth, het.thresh = 0.25, snp.nbhd = opt$snp_nbhd, 
		gbuild=gbuild, unmatched=opt$unmatched, ndepthmax=opt$maxNDepth)
	dmat <- facets:::counts2logROR(pmat[pmat$rCountT > 0, ], gbuild, unmatched=opt$unmatched)
        dmat$keep[which(dmat$gcpct>=opt$maxGC | dmat$gcpct<=opt$minGC)] <- 0
	dmat <- dmat[dmat$keep == 1,]
	tmp1 <- facets:::segsnps(dmat, opt$pre_cval, hetscale=F)
	pmat$keep <- 0
	pmat$keep[which(paste(pmat$chrom, pmat$maploc, sep="_") %in% paste(dmat$chrom, dmat$maploc, sep="_"))] <- 1

	tmp2 <- list(pmat = pmat, gbuild=gbuild, nX=nX)
	preOut <- c(tmp2,tmp1)
}

formatSegmentOutput <- function(out,sampID) {
	seg=list()
	seg$ID=rep(sampID,nrow(out$out))
	seg$chrom=out$out$chr
	seg$loc.start=rep(NA,length(seg$ID))
	seg$loc.end=seg$loc.start
	seg$num.mark=out$out$num.mark
	seg$seg.mean=out$out$cnlr.median
	for(i in 1:nrow(out$out)) {
		lims=range(out$jointseg$maploc[(out$jointseg$chrom==out$out$chr[i] & out$jointseg$seg==out$out$seg[i])],na.rm=T)
		seg$loc.start[i]=lims[1]
		seg$loc.end[i]=lims[2]
	}	
	as.data.frame(seg)
}

out <- preOut %>% procSample(cval = opt$cval, min.nhet = opt$min_nhet)

cat ("Completed preProc and proc\n")
cat ("procSample FLAG is", out$FLAG, "\n")

# save all objects except pileup
save(file = str_c(opt$outPrefix, ".Rdata"), list = ls()[!grepl("^rcmat", ls())],  compress=T)

# Run emncf, don't break if error:
print(str_c("attempting to run emncf() with cval = ", opt$cval))
fit <- tryCatch({
	out %>% emcncf
}, error = function(e) {
	print(paste("Error:", e))
	return(NULL)
})
if (!is.null(fit)) {
	cat ("emcncf was successful with cval", opt$cval, "\n")
	
	# make a table viewable in IGV
	out$IGV = formatSegmentOutput(out, opt$tumorName)
	
	# plot facets results
	if(sum(out$out$num.mark)<=10000) { height=4; width=7} else { height=6; width=9}
	pdf(file = str_c(opt$outPrefix, ".cncf.pdf"), height = height, width = width)
	plotSample(out, fit)
	dev.off()
	
	# save cncf table
	write.table(fit$cncf, str_c(opt$outPrefix, ".cncf.txt"), row.names = F, quote = F, sep = '\t')
	
	# save results and metrics
	ff = str_c(opt$outPrefix, ".out")
	cat("# Version =", version, "\n", file = ff, append = T)
	cat("# Input =", basename(baseCountFile), "\n", file = ff, append = T)
	cat("# tumor =", opt$tumorName, "\n", file = ff, append = T)
	cat("# snp.nbhd =", opt$snp_nbhd, "\n", file = ff, append = T)
	cat("# cval =", opt$cval, "\n", file = ff, append = T)
	cat("# min.nhet =", opt$min_nhet, "\n", file = ff, append = T)
	cat("# genome =", opt$genome, "\n", file = ff, append = T)
	cat("# Purity =", fit$purity, "\n", file = ff, append = T)
	cat("# Ploidy =", fit$ploidy, "\n", file = ff, append = T)
	cat("# dipLogR =", fit$dipLogR, "\n", file = ff, append = T)
	cat("# dipt =", fit$dipt, "\n", file = ff, append = T)
	cat("# loglik =", fit$loglik, "\n", file = ff, append = T)

} else {
	cat ("emcncf failed with cval", opt$cval, "\n")
	fit <- NULL
	ff = str_c(opt$outPrefix, ".out")
	cat("# Version =", version, "\n", file = ff, append = T)
	cat("# Input =", basename(baseCountFile), "\n", file = ff, append = T)
	cat("# tumor =", opt$tumorName, "\n", file = ff, append = T)
	cat("# snp.nbhd =", opt$snp_nbhd, "\n", file = ff, append = T)
	cat("# cval =", opt$cval, "\n", file = ff, append = T)
	cat("# min.nhet =", opt$min_nhet, "\n", file = ff, append = T)
	cat("# genome =", opt$genome, "\n", file = ff, append = T)
	cat("# Purity =", "failed", "\n", file = ff, append = T)
	cat("# Ploidy =", "failed", "\n", file = ff, append = T)
	cat("# dipLogR =", "failed", "\n", file = ff, append = T)
	cat("# dipt =", "failed", "\n", file = ff, append = T)
	cat("# loglik =", "failed", "\n", file = ff, append = T)
}

# save all objects except pileup
save(file = str_c(opt$outPrefix, ".Rdata"), list = ls()[!grepl("^rcmat", ls())],  compress=T)


warnings()

