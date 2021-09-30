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
    Junjun Zhang
*/

nextflow.enable.dsl = 2
version = '0.1.0'  // package version

// universal params go here, change default value as needed
params.container = ""
params.container_registry = ""
params.container_version = ""
params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir

// tool specific parmas go here, add / change as needed
params.input_file = ""
params.cleanup = true

params.ref_genome_build = 'hg38'  // GRCh38
params.ref_genome_fa = ""
params.tumour_aln_seq = ""
params.normal_aln_seq = ""
params.tumour_id = ""

params.donor_sex = "female"  // or "male"
params.gcwiggle = ""
params.dbsnp_file = ""
params.is_test = false  // must be explictly set to true when run as test


// seqzPreproces
seqzPreprocess_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  'tumor_bam': params.tumour_aln_seq,
  'normal_bam': params.normal_aln_seq,
  'gcwiggle': params.gcwiggle,
  'fasta': params.ref_genome_fa
]

// seqzMain
seqzMain_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir
]

// svaba
svaba_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  'sample_id': params.tumour_id,
  'input_tumour_bam': params.tumour_aln_seq,
  'input_normal_bam': params.normal_aln_seq,
  'ref_genome_gz': params.ref_genome_fa,
  'dbsnp_file': params.dbsnp_file
]

// facets
facets_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  'pileup': 'NO_FILE',
  'tumor_id': params.tumour_id,
  'genome': params.ref_genome_build
]

// battenberg
battenberg_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  'tumour_bam': params.tumour_aln_seq,
  'normal_bam': params.normal_aln_seq,
  'sex': params.donor_sex,
  'battenberg_ref_dir': 'input/battenberg_references',  // can't really use path as input
  'test': params.is_test
]

// snpPileup
snpPileup_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  'tumor': params.tumour_aln_seq,
  'normal': params.normal_aln_seq,
  'ref': params.ref_genome_fa + '.gz',
  'dbsnp': params.dbsnp_file
]

// manta
manta_params = [
  'cpus': params.cpus,
  'mem': params.mem,
  'publish_dir': params.publish_dir,
  'normalBam': params.tumour_aln_seq,
  'tumorBam': params.normal_aln_seq,
  'referenceFasta': params.ref_genome_fa
]


include { demoCopyFile } from "./local_modules/demo-copy-file"
include { getSecondaryFiles; getBwaSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main.nf' params([*:params, 'cleanup': false])
include { seqzPreprocess } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/seqz-preprocess@0.2.5/main.nf' params([*:seqzPreprocess_params, 'cleanup': false])
include { svaba } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/svaba@0.2.0/main.nf' params([*:svaba_params, 'cleanup': false])
include { facets } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/facets@0.3.0/main.nf' params([*:facets_params, 'cleanup': false])
include { battenberg } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/battenberg@0.1.0/main.nf' params([*:battenberg_params, 'cleanup': false])
include { snpPileup } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/snp-pileup@0.3.1/main.nf' params([*:snpPileup_params, 'cleanup': false])
include { manta } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/manta@0.2.0/main.nf' params([*:manta_params, 'cleanup': false])
include { seqzMain } from './wfpr_modules/github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number/seqz-main@0.2.5/main.nf' params([*:seqzMain_params, 'cleanup': false])


// please update workflow code as needed
workflow ArgoSvCnvCalling {
  take:  // update as needed
    input_file


  main:  // update as needed
    demoCopyFile(input_file)


  emit:  // update as needed
    output_file = demoCopyFile.out.output_file

}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  ArgoSvCnvCalling(
    file(params.input_file)
  )
}
