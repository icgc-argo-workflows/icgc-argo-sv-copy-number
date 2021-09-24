#!/usr/bin/env nextflow

/*
  Copyright (c) 2021, ICGC-ARGO-Structural-Variation-CN-WG

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
version = '0.3.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number.facets'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = default_container_registry
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 30  // GB
params.publish_dir = "facets_outdir"  // set to empty string will disable publishDir
params.help = null

// tool specific parmas go here, add / change as needed
params.tumor_id       = null
params.pileup         = null
params.genome         = 'hg38'
params.snp_nbhd       = 500
params.minNDepth      = 5
params.maxNDepth      = 500
params.pre_cval       = 80
params.cval           = 200
params.min_nhet       = 25
params.unmatched      = 'FALSE'
params.minGC          = 0
params.maxGC          = 1
params.seed           = 1234
params.facetsRun      = "${baseDir}/scripts/facetsRun.R"
params.Facets_myplot  = "${baseDir}/scripts/runFacets_myplot.R"

def helpMessage() {
    log.info"""

USAGE

The typical command for running the pipeline is as follows:
    nextflow run facets/main.nf --pileup <snp-pileup.bc.gz>

Mandatory arguments:
    --tumor_id      Tumor ID
    --pileup        Pileup file produced by snp-pileup (.bc.gz)

Optional arguments:
    --genome        Genome build (b37, GRCh37, hg19, mm9, mm10, GRCm38, hg38). [${params.genome}]
    --seed          [${params.seed}]
    --snp_nbhd      Window size. For WES use 250, for WGS use 500 [${params.snp_nbhd}]
    --minNDepth     Minimum depth in normal to keep the position. For WES 25 is reasonable, for WGS 5. [${params.minNDepth}]
    --maxNDepth     Maximum depth in normal to keep the position. For WES 1000 is reasonable, for WGS 300 [${params.maxNDepth}]
    --pre_cval      Pre-processing critical value [${params.pre_cval}]
    --cval          Critical value for estimating diploid log Ratio [${params.cval}]
    --min_nhet      Minimum number of heterozygote snps in a segment used for bivariate t-statistic during clustering of segment [${params.min_nhet}]
    --unmatched     Is the tumor sample unmatched? [${params.unmatched}]
    --minGC         Min GC of position [${params.minGC}]
    --maxGC         Max GC of position [${params.maxGC}]
    """.stripIndent()
}

if (params.help) exit 0, helpMessage()

log.info ""
log.info "tumor_id=${params.tumor_id}"
log.info "pileup=${params.pileup}"
log.info "genome=${params.genome}"
log.info ""


// Validate inputs
if(params.tumor_id == null) error "Missing mandatory '--tumor_id' parameter"
if(params.pileup == null) error "Missing mandatory '--pileup' parameter"


process facets {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:
    path pileup


  output:
    path "*.Rdata", emit: output_Rdata
    path "*.out", emit: output_summary
    path "*.cncf.txt", optional: true, emit: output_cncf
    path "*.cncf.pdf", optional: true, emit: output_plot


  shell:
    '''
        facetsRun.R --seed !{params.seed} --minNDepth !{params.minNDepth} --maxNDepth !{params.maxNDepth} --snp_nbhd !{params.snp_nbhd} --minGC !{params.minGC} --maxGC !{params.maxGC} --cval !{params.cval} --pre_cval !{params.pre_cval} --genome !{params.genome} --min_nhet !{params.min_nhet} --outPrefix !{params.tumor_id} --tumorName !{params.tumor_id} !{pileup}
    '''
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  facets(
    file(params.pileup)
  )
}
