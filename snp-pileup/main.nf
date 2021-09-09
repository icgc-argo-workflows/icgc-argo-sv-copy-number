#!/usr/bin/env nextflow

/*
  Copyright (c) 2021, ICGC ARGO

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    Andrej Benjak
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.3.0'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/wfpm-demo.snp-pileup'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir
params.help = null

// tool specific parmas go here, add / change as needed
params.tumor          = ""
params.normal         = ""
params.dbsnp          = "${baseDir}/resources/dbsnp_151.common.hg38.vcf.gz"
params.ref            = ""
params.q              = 15
params.Q              = 20
params.r              = '5,0'
params.d              = 1000
params.P              = 500
params.output_pattern = "*.bc.gz"  // output file name pattern



def helpMessage() {
    log.info"""

USAGE

The typical command for running the pipeline is as follows:
    nextflow run snp-pileup/main.nf --tumor <tumor BAM/CRAM> --normal <normal BAM/CRAM> --ref <reference genome> --dbsnp <dbsnp vcf>

Mandatory arguments:
    --tumor     Path to the tumor file (BAM or CRAM).
    --normal    Path to the normal file (BAM or CRAM).
    --ref       Path to the reference genome file (the same as the one used for cram/bam).
                The *.fai index must be available, as well as the *.gzi in case of a compressed fasta file.
    --dbsnp     Path to the germline resource VCF.
                Default is 'snp-pileup/resources/dbsnp_151.common.hg38.vcf.gz'.
                You need to execute 'snp-pileup/scripts/fetch_resources.sh' to fetch this file before you can run this module.

Optional arguments:
    --r         Minimum tumor and normal read counts for a position, in that order. [${params.r}]
    --q         Sets the minimum threshold for mapping quality [${params.q}]
    --Q         Sets the minimum threshold for base quality [${params.Q}]
    --d         Sets the maximum depth [${params.d}]
    --P         Insert a pseudo SNP every [${params.P}] positions, with the total count at that position.
                This is used to reduce large gaps between consecutive SNPs and still get consistent read counts across the genome.
    """.stripIndent()
}

if (params.help) exit 0, helpMessage()

log.info ""
log.info "Running snp-pileup using the following files:"
log.info "  tumor     = ${params.tumor}"
log.info "  normal    = ${params.normal}"
log.info "  reference = ${params.ref}"
log.info "  dbSNP     = ${params.dbsnp}"
log.info ""


// Validate inputs
if(params.tumor == null) error "Missing mandatory '--tumor' parameter"
if(params.normal == null) error "Missing mandatory '--normal' parameter"
if(params.ref == null) error "Missing mandatory '--ref' parameter"

include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo/data-processing-utility-tools/helper-functions@1.0.1/main.nf'

process snpPileup {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path tumor
    path normal
    path dbsnp
    path ref
    path ref_idx

  output:  // output, make update as needed
    path "${params.output_pattern}", emit: output_file

  shell:
    '''
    main.sh -t !{tumor} -n !{normal} -g !{ref} -s !{dbsnp} -P !{params.P} -d !{params.d} -q !{params.q} -Q !{params.Q} -r !{params.r} -o !{tumor}.bc.gz
    '''
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  snpPileup(
    file(params.tumor),
    file(params.normal),
    file(params.dbsnp),
    file(params.ref),
    Channel.fromPath(getSecondaryFiles(params.ref, ['fai','gzi']), checkIfExists: false).collect(),
  )
}
