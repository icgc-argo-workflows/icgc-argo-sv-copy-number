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
    Kate Eason
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.1'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/icgc-argo-sv-copy-number.battenberg'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1 // Battenberg only parallelises to as many jobs as there are chromosomes, so the max cpus that is useful is 24
params.mem = 16  // GB
params.publish_dir = ""  // set to empty string will disable publishDir


// tool specific parmas go here, add / change as needed
params.tumour_bam = ""
params.normal_bam = ""
params.fasta_file = ""
params.sex = ""
params.battenberg_ref_dir = ""
params.test = false

params.output_pattern = "*_subclones.txt"  // output file name pattern

include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main.nf'

process battenberg {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path tumour_bam
    path tumour_bai
    path normal_bam
    path normal_bai
    path fasta_file
    path fasta_fai
    path battenberg_ref_dir

  output:  // output, make update as needed
    path "${params.output_pattern}", emit: output_file

  script:

    // add and initialize variables here as needed

    arg_test = params.test ? "--test" : ""

      """
      mkdir -p output_dir
      
      run_battenberg.R \
      -t ${tumour_bam} \
      -n ${normal_bam} \
      --sex ${params.sex} \
      -f ${fasta_file} \
      -r ${battenberg_ref_dir} \
      --imputeinfofile ${battenberg_ref_dir}/impute_info.txt \
      --cpu ${params.cpus} ${arg_test}
      
      """
      
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  battenberg(
    file(params.tumour_bam),
    Channel.fromPath(getSecondaryFiles(params.tumour_bam,['{b,cr}ai']), checkIfExists: true).collect(),
    file(params.normal_bam),
    Channel.fromPath(getSecondaryFiles(params.normal_bam,['{b,cr}ai']), checkIfExists: true).collect(),
    file(params.fasta_file),
    Channel.fromPath(getSecondaryFiles(params.fasta_file,['fai']), checkIfExists: true).collect(),
    file(params.battenberg_ref_dir)
  )
}
