set.seed(1234)

##################################
# Load packages and parse inputs #
##################################
library("optparse")
library(sequenza)

# define argument list and data types
option_list <- list(
  make_option("--seqz", type="character", default = NULL, 
              help="-", metavar="character"),
  make_option("--genome", type="character", default = NULL, 
              help="-", metavar="character")
)

# parse arguments
opt_parser <- OptionParser(option_list = option_list)
opt        <- parse_args(opt_parser)

# check if mandatory arguments were provided, show help menu otherwise
if (is.null(opt[["seqz"]]) | is.null(opt[["genome"]])) {
  print_help(opt_parser)
  print(opt)
  stop("One or more mandatory arguments missing.", call.=FALSE)
}

sample_id = sub("_bin50.seqz.gz|.seqz.txt.gz", "", opt[["seqz"]])


# process seqz data, normalization and segmentation
seqz <- sequenza.extract(opt[["seqz"]], assembly = opt[["genome"]])

# run grid-search approach to estimate cellularity and ploidy
CP <- sequenza.fit(seqz)

# write files and plots using suggested or selected solution
sequenza.results(sequenza.extract = seqz, cp.table = CP, sample.id = sample_id)


# This is not in the results by default: Plot of the log posterior probability with respective cellularity and ploidy probability distribution and confidence intervals.

cint <- get.ci(CP)

pdf(paste0(sample_id,"_CP_contours_post_prob_distr.pdf"))
par(mfrow = c(2,2))
cp.plot(CP)
cp.plot.contours(CP, add = TRUE)
plot(cint$values.cellularity, ylab = "Cellularity",
    xlab = "posterior probability", type = "n")
select <- cint$confint.cellularity[1] <= cint$values.cellularity[,2] &
         cint$values.cellularity[,2] <= cint$confint.cellularity[2]
polygon(y = c(cint$confint.cellularity[1], cint$values.cellularity[select, 2], cint$confint.cellularity[2]),
       x = c(0, cint$values.cellularity[select, 1], 0), col='red', border=NA)
lines(cint$values.cellularity)
abline(h = cint$max.cellularity, lty = 2, lwd = 0.5)
plot(cint$values.ploidy, xlab = "Ploidy",
    ylab = "posterior probability", type = "n")
select <- cint$confint.ploidy[1] <= cint$values.ploidy[,1] &
         cint$values.ploidy[,1] <= cint$confint.ploidy[2]
polygon(x = c(cint$confint.ploidy[1], cint$values.ploidy[select, 1], cint$confint.ploidy[2]),
       y = c(0, cint$values.ploidy[select, 2], 0), col='red', border=NA)
lines(cint$values.ploidy)
abline(v = cint$max.ploidy, lty = 2, lwd = 0.5)
dev.off()

# Save R session
save.image(paste0(sample_id,"_sequenza_session.RData"))
