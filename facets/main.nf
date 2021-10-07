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
version = '0.4.1'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/icgc-argo-sv-copy-number.facets'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = default_container_registry
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 30  // GB
params.publish_dir = ""  // set to empty string will disable publishDir
params.help = null

// tool specific parmas go here, add / change as needed
params.out_prefix     = null
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
    --pileup        Pileup file produced by snp-pileup (.bc.gz)
    --out_prefix    Output prefix

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

// Validate inputs
if(params.out_prefix == null) error "Missing mandatory '--out_prefix' parameter"

log.info ""
log.info "pileup=${params.out_prefix}"
log.info "pileup=${params.pileup}"
log.info "genome=${params.genome}"
log.info ""


process facets {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:
    path pileup


  output:
    path "*.tgz", emit: facets_results


  shell:
    '''
        #run facets
        facetsRun.R --seed !{params.seed} --minNDepth !{params.minNDepth} --maxNDepth !{params.maxNDepth} --snp_nbhd !{params.snp_nbhd} --minGC !{params.minGC} --maxGC !{params.maxGC} --cval !{params.cval} --pre_cval !{params.pre_cval} --genome !{params.genome} --min_nhet !{params.min_nhet} --outPrefix !{params.out_prefix} --tumorName !{params.out_prefix} !{pileup}
        
        #fetch results (cncf and plot can be missing from facets results, but if produced both will be available)
        facetsResults.sh -s !{params.out_prefix}.out $(if [[ -f !{params.out_prefix}.cncf.txt && -f !{params.out_prefix}.cncf.pdf ]]; then echo -c !{params.out_prefix}.cncf.txt -p !{params.out_prefix}.cncf.pdf; fi)
    '''
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  facets(
    file(params.pileup)
  )
}
