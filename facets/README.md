# FACETS

FACETS (Fraction and Allele specific Copy number Estimate from Tumor/normal Sequencing) infers allele-specific  DNA copy number and clonal heterogeneity from high-throughput sequencing including whole-genome, whole-exome, and some targeted cancer gene panels. The method implements a bivariate genome segmentation, followed by allele-specific copy number calls. Tumor purity,ploidy, and cellular fractions are estimated and reported from the output. This tool is useful to simplify large-scale application providing comprehensive output, and integrated visualization.

Read more: [https://github.com/mskcc/facets/](https://github.com/mskcc/facets/)

## Usage

Mandatory arguments:
```
    --pileup        Pileup file produced by snp-pileup (.bc.gz)
    --out_prefix    Output prefix
```

Optional arguments:
```
    --genome        Genome build (b37, GRCh37, hg19, mm9, mm10, GRCm38, hg38). [hg38]
    --seed          [1234]
    --snp_nbhd      Window size [250]
    --minNDepth     Minimum depth in normal to keep the position [5]
    --maxNDepth     Maximum depth in normal to keep the position [500]
    --pre_cval      Pre-processing critical value [80]
    --cval          Critical value for estimating diploid log Ratio [200]
    --min_nhet      Minimum number of heterozygote snps in a segment used for bivariate t-statistic during clustering of segment [25]
    --unmatched     Is it unmatched? [FALSE]
    --minGC         Min GC of position [0]
    --maxGC         Max GC of position [1]
```

## Output
```
 .cncf.pdf ...... genome-wide profile. Figures:
                  log-ratio: logR  with  chromosomes  alternating  in  blue  and gray. The green line indicates the median logR in the sample. The purple line indicates the logR of the diploid state.
                  log-odds-ratio: Segment means are ploted in red lines.
                  copy number (em): plots the total (black) and minor (red) copy number for each segment.
                  cf-em: shows the associated cellular fraction (cf). Dark blue indicates high cf. Light blue indicates low cf. Beige indicates a normal segment (total=2,minor=1).
 .cncf.txt ...... FACETS result table. The columns are:
                  chrom: the chromosome to which the segment belongs.seg: the segment number.
                  num.mark: the number of SNPs in the segment.
                  nhet: the number of SNPs that are deemed heterozygous.
                  cnlr.median: the median log-ratio of the segment.
                  mafR: the log-odds-ratio summary for the segment (close to zero means the alleles are in balance).
                  segclust: the segment cluster to which segment belongs.
                  cnlr.median.clust: the median log-ratio of the segment cluster.
                  mafR.clust: the log-odds-ratio summary for the segment cluster.
                  cf.em: the cellular fraction of the segment.
                  tcn.em: the total copy number of the segment.
                  lcn.em: the minor copy number of the segment.
 .out ........... result summary file and log
 .Rdata ......... FACETS R session

```
