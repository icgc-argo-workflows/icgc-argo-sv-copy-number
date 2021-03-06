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
    lDesiree
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.3.0'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/icgc-argo-sv-copy-number.seqz-main'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 4
params.mem = 16  // GB
params.publish_dir = "output_dir/"  // set to empty string will disable publishDir


// tool specific parmas go here, add / change as needed
params.seqz = ""
params.genome = "hg38"
params.sampleID = "sample"
//params.output_pattern = "*_*" // output file name pattern are *.pdf|*.txt|*.RData


process seqzMain {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path seqz

  output:  // output, make update as needed
    path "*.tgz", emit: sequenza_results
    path "${params.sampleID}_segments.txt", emit: segments

  shell:
    // add and initialize variables here as needed

    """
    # run sequenza
    Rscript /tools/runSequenza.R --seqz !{seqz} --genome !{params.genome} --sampleID !{params.sampleID}

    # fetch results
    bash /tools/maketar.sh \
    --fit "!{params.sampleID}_alternative_fit.pdf" \
    --solutions "!{params.sampleID}_alternative_solutions.txt" \
    --depths "!{params.sampleID}_chromosome_depths.pdf" \
    --chrview "!{params.sampleID}_chromosome_view.pdf" \
    --bars "!{params.sampleID}_CN_bars.pdf" \
    --confints "!{params.sampleID}_confints_CP.txt" \
    --contours "!{params.sampleID}_CP_contours.pdf" \
    --contpost "!{params.sampleID}_CP_contours_post_prob_distr.pdf" \
    --gc "!{params.sampleID}_gc_plots.pdf" \
    --genomeview "!{params.sampleID}_genome_view.pdf" \
    --modelfit "!{params.sampleID}_model_fit.pdf" \
    --mutations "!{params.sampleID}_mutations.txt" \
    --segments "!{params.sampleID}_segments.txt" \
    --cptable "!{params.sampleID}_sequenza_cp_table.RData" \
    --extract "!{params.sampleID}_sequenza_extract.RData" \
    --log "!{params.sampleID}_sequenza_log.txt" \
    --session "!{params.sampleID}_sequenza_session.RData"
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  seqzMain(
    file(params.seqz)
  )
}
