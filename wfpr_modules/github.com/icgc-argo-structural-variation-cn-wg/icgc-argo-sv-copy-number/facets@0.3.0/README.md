# FACETS

FACETS (Fraction and Allele specific Copy number Estimate from Tumor/normal Sequencing) infers allele-specific  DNA copy number and clonal heterogeneity from high-throughput sequencing including whole-genome, whole-exome, and some targeted cancer gene panels. The method implements a bivariate genome segmentation, followed by allele-specific copy number calls. Tumor purity,ploidy, and cellular fractions are estimated and reported from the output. This tool is useful to simplify large-scale application providing comprehensive output, and integrated visualization.

Read more: [https://github.com/mskcc/facets/](https://github.com/mskcc/facets/)

## Usage

The typical command for running the pipeline is as follows:

```
nextflow run wes-postproc/modules/facets --input input.txt -profile cluster,singularity
```

Mandatory arguments:
```
    --input         Tab delimited file (no header), with paths to following files:
                    tumor_ID    normal_ID    tumor.bam    normal.bam    target.dbsnp
```

Optional arguments:
```
    --snp_pileup    Full path to the folder containing the snp_pileup files (you might want to use this when re-running facets)
    --summaryPrefix Prefix for the summary files [all.geneCN]
    --q             (snp-pileup) Sets the minimum threshold for mapping quality [1]
    --Q             (snp-pileup) Sets the minimum threshold for base quality [13]
    --r             (snp-pileup) Comma separated list of minimum read counts for a position to be output [25,0]
    --d             (snp-pileup) Sets the maximum depth [1000]
    --genome        Genome build (b37, GRCh37, hg19, mm9, mm10, GRCm38, hg38). [hg38]
    --seed          [1234]
    --snp_nbhd      Window size [250]
    --minNDepth     Minimum depth in normal to keep the position [25]
    --maxNDepth     Maximum depth in normal to keep the position [1000]
    --pre_cval      Pre-processing critical value [cval1 - 50]
    --cval1         Critical value for estimating diploid log Ratio [200]
    --cval2         Starting critical value for segmentation (increases by 25 until success) [cval1 - 50]
    --max_cval      Maximum critical value for segmentation (increases by 25 until success) [5000]
    --min_nhet      Minimum number of heterozygote snps in a segment used for bivariate t-statistic during clustering of segment [25]
    --unmatched     Is it unmatched? [FALSE]
    --minGC         Min GC of position [0]
    --maxGC         Max GC of position [1]
```

## Output
```
./facets_out/snp_pileup .................. pileup files for every sample.
    {tumor_id}__{normal_id}__q{params.q}_Q{params.Q}_d{params.maxNDepth}_r{params.r}.bc.gz



./facets_out/cval1{params.cval1} .......... FACETS results for every sample.
    {tumor_id}__{normal_id}.cncf.pdf ...... genome-wide profile. Figures:
                                            log-ratio: logR  with  chromosomes  alternating  in  blue  and gray. The green line indicates the median logR in the sample. The purple line indicates the logR of the diploid state.
                                            log-odds-ratio: Segment means are ploted in red lines.
                                            copy number (em): plots the total (black) and minor (red) copy number for each segment.
                                            cf-em: shows the associated cellular fraction (cf). Dark blue indicates high cf. Light blue indicates low cf. Beige indicates a normal segment (total=2,minor=1).
    {tumor_id}__{normal_id}.cncf.txt ...... FACETS result table. The columns are:
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
    {tumor_id}__{normal_id}.logR.pdf ...... genome-wide profile log-ratio only.
    {tumor_id}__{normal_id}.out ........... result summary file and log
    {tumor_id}__{normal_id}.Rdata ......... FACETS R session

```

## Fetching the singularity container
```
bash scripts/fetch_image.sh
```

## Fetching resource files
```
bash scripts/fetch_resources.sh
```
