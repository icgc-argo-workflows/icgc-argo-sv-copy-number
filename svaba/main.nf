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
    alvinwt
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number.svaba'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""
params.workdir = ''
params.cpus = 1
params.mem = 4  // GB
params.publish_dir = ""  // set to empty string will disable publishDir

// tool specific parmas go here, add / change as needed
params.input_tumour_bam = ""
params.input_normal_bam = ""
params.sample_id        = ""
params.dbsnp_file       = "reference/af-only-gnomad.pass-only.hg38.INDELS-chr3.vcf"
params.ref_genome_gz    = ""
params.ref_genome_fai   = file(params.ref_genome_gz + '.fai')
params.output_pattern   = "*.html"  // output file name pattern

input_tumour_bai = file(params.input_tumour_bam + '.bai')
input_normal_bai = file(params.input_normal_bam + '.bai')

process svaba {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path input_tumour_bam
    path input_normal_bam
    path input_tumour_bai
    path input_normal_bai

  output:  // output, make update as needed
    path "${params.sample_id}/${params.sample_id}.svaba.somatic.indel.vcf", emit: output_file

  script:
    // add and initialize variables here as needed

    """
    mkdir -p ${params.sample_id}
    svaba run -t ${input_tumour_bam} \
-n ${input_normal_bam} \
-G ${baseDir}/${params.ref_genome_gz} \
-p ${params.mem} \
-a ${params.sample_id} \
-D ${baseDir}/${params.dbsnp_file}

    mv ${params.sample_id}.* ${params.sample_id}/
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
svaba(
params.input_tumour_bam,
params.input_normal_bam,
input_tumour_bai,
input_normal_bai
)
}
