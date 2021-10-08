Battenberg
==========

This tool will run the [Battenberg copy number caller](https://www.ncbi.nlm.nih.gov/pubmed/22608083), which can call subclonal copy number profiles from whole genome sequencing. This tool contains a version of the [Battenberg source code](https://github.com/Wedge-lab/battenberg) adapted to work with GRCh38.


# Testing installation

Test the pipeline is working correctly using `wfpm`:

```
> wfpm test
Testing package: /icgc-argo-sv-copy-number/battenberg
[1/1] Testing: /icgc-argo-sv-copy-number/battenberg/tests/test-job-1.json. PASSED
Tested package: battenberg, PASSED: 1, FAILED: 0

```

Note that for Battenberg to run with tiny test files, some data has to be faked. **The `--test` argument should never be set to `true` with real data**. Also, the reference files used for testing in the battenberg_references folder are truncated and **should not be used with real data**.

# Usage

```
nextflow run main.nf --tumour_bam <tumour BAM file> --tumour_bai <tumour BAM index file> --normal_bam <normal BAM file> --normal_bai <normal BAM index file> --battenberg_ref_dir <path to Battenberg reference directory> --battenberg_impute_info <path to impute_info.txt> --sex <male|female>
```
The path `--battenberg_ref_dir` should point to the `battenberg_references` directory, under which all the subdirectories with the required GRCh38 reference files should be placed:

```
> ls battenberg_references
battenberg_references/
├── 1000G_loci_hg38
├── beagle5
├── GC_correction_hg38
├── imputation
├── RT_correction_hg38
├── shapeit2
├── impute_info.txt
└── probloci.txt.gz

```

# Output

Alongside various plots, the main output is the file `<tumour BAM file>_subclones.txt`, along with purity estimates in `<tumour BAM file>_rho_and_psi.txt`. Detailed information on all outputs can be found [here](https://github.com/Wedge-lab/battenberg#description-of-the-output).
