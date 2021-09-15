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
    Desiree Schnidrig
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/wfpm-demo.seqz-preprocess'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = "output_dir/"  // set to empty string will disable publishDir


// tool specific parmas go here, add / change as needed
params.tumor_bam      = ""
params.normal_bam     = ""
params.fasta          = ""
params.gcwiggle       = "${baseDir}/resources/hg38.gc50Base.wig.gz"
params.output_pattern = "*bin50.seqz.gz"  // output file name pattern

process seqzPreprocess {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path tumor_bam
    path normal_bam
    path fasta
    path gcwiggle

  output:  // output, make update as needed
    path "${params.output_pattern}", emit: seqz

  script:
    // add and initialize variables here as needed

    """
    sequenza-utils bam2seqz --normal ${normal_bam} --tumor ${tumor_bam} --fasta ${fasta} -gc ${gcwiggle} --output sample.seqz.gz;
    sequenza-utils seqz_binning --seqz sample.seqz.gz --window 50 -o sample_bin50.seqz.gz
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  seqzPreprocess(
    file(params.tumor_bam),
    file(params.normal_bam),
    file(params.fasta),
    file(params.gcwiggle)
  )
}
