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

nextflow.enable.dsl = 2
version = '0.2.0.1'

// universal params go here, change default value as needed
params.container = ""
params.container_registry = ""
params.container_version = ""
params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir

// tool specific parmas go here, add / change as needed
params.tumor   = ""
params.normal  = ""
params.dbsnp   = "${baseDir}/resources/dbsnp_151.common.hg38.vcf.gz"
params.ref     = ""
params.cleanup = true

include { getSecondaryFiles; snpPileup } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/snp-pileup@0.3.1/main.nf' params([*:params, 'cleanup': false])
include { facets } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/facets@0.4.1/main.nf' params([*:params, 'cleanup': false])

// please update workflow code as needed
workflow FacetsWf {

  take:
    tumor
    normal
    dbsnp
    ref
    ref_idx


  main:
    snpPileup(
      tumor,
      normal,
      dbsnp,
      ref,
      ref_idx
    )

    facets(
      snpPileup.out.output_file
    )


  emit:
    results = facets.out.facets_results

}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  FacetsWf(
    file(params.tumor),
    file(params.normal),
    file(params.dbsnp),
    file(params.ref),
    Channel.fromPath(getSecondaryFiles(params.ref, ['fai','gzi']), checkIfExists: false).collect(),
  )
}
