#!/usr/local/bin/Rscript --vanilla

library(BattenbergHG38)
library(optparse)

option_list = list(
  make_option(c("-t", "--tumourbam"), type="character", default=NULL, help="Tumour BAM/CRAM file", metavar="character"),
  make_option(c("-n", "--normalbam"), type="character", default=NULL, help="Normal BAM/CRAM file", metavar="character"),
  make_option(c("--sex"), type="character", default=NULL, help="Sex of the sample", metavar="character"),
  make_option(c("-f", "--fastafile"), type="character", default=NULL, help="Path to fasta file used for CRAM alignment", metavar="character"),
  make_option(c("-r", "--reference"), type="character", default=".", help="Directory where Battenberg reference files are found", metavar="character"),
  make_option(c("-i", "--imputeinfofile"), type="character", default=".", help="Impute info file", metavar="character"),
  make_option(c("--tumourname"), type="character", default=NULL, help="Samplename of the tumour", metavar="character"),
  make_option(c("--normalname"), type="character", default=NULL, help="Samplename of the normal", metavar="character"),
  make_option(c("--cpu"), type="numeric", default=1, help="The number of CPU cores to be used by the pipeline (Default: 8)", metavar="character"),
  make_option(c("--skip_allelecount"), type="logical", default=FALSE, action="store_true", help="Provide when alleles don't have to be counted. This expects allelecount files on disk", metavar="character"),
  make_option(c("--skip_preprocessing"), type="logical", default=FALSE, action="store_true", help="Provide when pre-processing has previously completed. This expects the files on disk", metavar="character"),
  make_option(c("--skip_phasing"), type="logical", default=FALSE, action="store_true", help="Provide when phasing has previously completed. This expects the files on disk", metavar="character"),
  make_option(c("--bp"), type="character", default=NULL, help="Optional two column file (chromosome and position) specifying prior breakpoints to be used during segmentation", metavar="character"),
  make_option(c("--test"), type="logical", default=FALSE, action="store_true", help="Testing run which adds some fake data to allow enough data for Battenberg to run on small test files", metavar="character")
  )

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

TUMOURBAM              = opt$tumourbam
NORMALBAM              = opt$normalbam
IS.MALE                = opt$sex=="male" | opt$sex=="Male" | opt$sex=="m" | opt$sex=="M"
FASTA                  = opt$fastafile
REF_DIR                = opt$r
TUMOURNAME             = ifelse( !is.null(opt$tumourname), opt$tumourname, gsub(".bam", "", basename(opt$tumourbam)) )
NORMALNAME             = ifelse( !is.null(opt$normalname), opt$normalname, gsub(".bam", "", basename(opt$normalbam)) )
SKIP_ALLELECOUNTING    = opt$skip_allelecount
SKIP_PREPROCESSING     = opt$skip_preprocessing
SKIP_PHASING           = opt$skip_phasing
NTHREADS               = opt$cpu
PRIOR_BREAKPOINTS_FILE = opt$bp
TESTING                = opt$test
IMPUTEINFOFILE         = opt$imputeinfofile

# General static
G1000PREFIX         = paste0(REF_DIR, "/1000G_loci_hg38/1kg.phase3.v5a_GRCh38nounref_allele_index_")
G1000PREFIX_AC      = paste0(REF_DIR, "/1000G_loci_hg38/1kg.phase3.v5a_GRCh38nounref_loci_chrstring_")
GCCORRECTPREFIX     = paste0(REF_DIR, "/GC_correction_hg38/1000G_GC_")
REPLICCORRECTPREFIX = paste0(REF_DIR, "/RT_correction_hg38/1000G_RT_")
IMPUTE_EXE          = "impute2"

# WGS specific static
ALLELECOUNTER = "alleleCounter"
PROBLEMLOCI   = paste0(REF_DIR, "/probloci.txt.gz")

PLATFORM_GAMMA        = 1
PHASING_GAMMA         = 1
SEGMENTATION_GAMMA    = 10
SEGMENTATIIN_KMIN     = 3
PHASING_KMIN          = 1
CLONALITY_DIST_METRIC = 0
ASCAT_DIST_METRIC     = 1
MIN_PLOIDY            = 1.6
MAX_PLOIDY            = 4.8
MIN_RHO               = 0.1
MIN_GOODNESS_OF_FIT   = 0.63
BALANCED_THRESHOLD    = 0.51
MIN_NORMAL_DEPTH      = 10
MIN_BASE_QUAL         = 20
MIN_MAP_QUAL          = 35
CALC_SEG_BAF_OPTION   = 3

if(TESTING){
  message('**** Testing mode active. Results will not be accurate. ****')
}

battenberg(tumourname        = TUMOURNAME,
 normalname                  = NORMALNAME,
 tumour_data_file            = TUMOURBAM,
 normal_data_file            = NORMALBAM,
 ismale                      = IS.MALE,
 fasta.file                  = FASTA,
 imputeinfofile              = IMPUTEINFOFILE,
 g1000prefix                 = G1000PREFIX,
 g1000allelesprefix          = G1000PREFIX_AC,
 gccorrectprefix             = GCCORRECTPREFIX,
 repliccorrectprefix         = REPLICCORRECTPREFIX,
 problemloci                 = PROBLEMLOCI,
 data_type                   = "wgs",
 impute_exe                  = IMPUTE_EXE,
 allelecounter_exe           = ALLELECOUNTER,
 nthreads                    = NTHREADS,
 platform_gamma              = PLATFORM_GAMMA,
 phasing_gamma               = PHASING_GAMMA,
 segmentation_gamma          = SEGMENTATION_GAMMA,
 segmentation_kmin           = SEGMENTATIIN_KMIN,
 phasing_kmin                = PHASING_KMIN,
 clonality_dist_metric       = CLONALITY_DIST_METRIC,
 ascat_dist_metric           = ASCAT_DIST_METRIC,
 min_ploidy                  = MIN_PLOIDY,
 max_ploidy                  = MAX_PLOIDY,
 min_rho                     = MIN_RHO,
 min_goodness                = MIN_GOODNESS_OF_FIT,
 uninformative_BAF_threshold = BALANCED_THRESHOLD,
 min_normal_depth            = MIN_NORMAL_DEPTH,
 min_base_qual               = MIN_BASE_QUAL,
 min_map_qual                = MIN_MAP_QUAL,
 calc_seg_baf_option         = CALC_SEG_BAF_OPTION,
 skip_allele_counting        = SKIP_ALLELECOUNTING,
 skip_preprocessing          = SKIP_PREPROCESSING,
 skip_phasing                = SKIP_PHASING,
 prior_breakpoints_file      = PRIOR_BREAKPOINTS_FILE,
 testingKE                   = TESTING)
