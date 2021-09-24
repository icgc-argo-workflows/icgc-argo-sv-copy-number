# seqz-main
==========

This tool will run [Sequenza](https://cran.r-project.org/web/packages/sequenza/vignettes/sequenza.html), an R package to analyze genomic sequencing data from paired normal-tumor samples, including cellularity and ploidy estimation; mutation and copy number (allele-specific and total copy number) detection, quantification and visualization.
This tool contains an [adapted version](https://github.com/aroneklund/copynumber) of the sequenza-dependency package [copynumber](https://bioconductor.org/packages/release/bioc/html/copynumber.html) which includes hg38 cytobands.


## Usage

The typical command for running the pipeline is as follows:

```
nextflow run seqz-main/main.nf --tumor <tumor BAM/CRAM> --normal <normal BAM/CRAM> --ref <reference genome> --dbsnp <dbsnp vcf>
```

Mandatory arguments:
```
    --seqz     Path to the seqz file. See sequenza documentation for more details. This seqz file can be generated with the tool 'seqz-preprocess'.
```

Optional arguments:
```
    --genome   Genome build. Options which have been tested are 'hg19' and 'hg38'. Theoretically, older builds (hg16-hg18) are also supported. [hg38]
```

## Output

Alongside various plots, the main outputs are the files 
sample_segments.txt                 Detected segments, with estimated allelic copy number for each segment
sample_alternative_solutions.txt    All ploidy/cellularity solutions with the default solution in the first row
sample_mutations.txt                All mutations and estimated number of mutated alleles (Mt)

Detailed information on all outputs can be found in the [sequenza documentation](https://cran.r-project.org/web/packages/sequenza/vignettes/sequenza.html).
