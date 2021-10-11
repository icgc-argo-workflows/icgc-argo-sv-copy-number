# snp-pileup

This application will, given a VCF file containing known germline SNP locations, output for
each SNP the counts of the reference nucleotide, alternative nucleotide,
errors, and deletions. These counts can then be used in `facets`.

Read more: [snp-pileup](https://github.com/mskcc/facets/tree/master/inst/extcode)

## Usage

The typical command for running the pipeline is as follows:

```
nextflow run snp-pileup/main.nf --tumor <tumor BAM/CRAM> --normal <normal BAM/CRAM> --ref <reference genome> --dbsnp <dbsnp vcf>
```

Mandatory arguments:
```
    --tumor     Path to the tumor file (BAM or CRAM).
    --normal    Path to the normal file (BAM or CRAM).
    --ref       Path to the reference genome file (the same as the one used for cram/bam).
                The *.fai index must be available, as well as the *.gzi in case of a compressed fasta file.
    --dbsnp     Path to the germline resource VCF.
                Default is 'snp-pileup/resources/dbsnp_151.common.hg38.vcf.gz'.
                You need to execute 'snp-pileup/scripts/fetch_resources.sh' to fetch this file before you can run this module.
```

Optional arguments:
```
    --r             Minimum tumor and normal read counts for a position, in that order. [5,0]
    --q             Sets the minimum threshold for mapping quality [15]
    --Q             Sets the minimum threshold for base quality [20]
    --d             Sets the maximum depth [1000]
    --P             Insert a pseudo SNP every 100 positions, with the total count at that position.
                    This is used to reduce large gaps between consecutive SNPs and still get consistent read counts across the genome.
```

## Output
```
./outdir/snpPileup/output_dir/$(basename !{tumor_bam} .bam).bc.gz

```

## Fetching the resource VCF
```
bash snp-pileup/scripts/fetch_resources.sh
```
Will save `snp-pileup/resources/dbsnp_151.common.hg38.vcf.gz`

