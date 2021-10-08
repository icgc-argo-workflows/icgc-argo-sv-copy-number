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

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.0.1'

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number.battenberg'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.tumour_bam = ""
params.normal_bam = ""
params.sex = ""
params.fasta_file = ""
params.battenberg_ref_dir = ""
params.expected_output = ""

params.tumour_bai = ""
params.normal_bai = ""
params.fasta_fai = ""

include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main.nf'

include { battenberg } from '../main'


process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_file
    path expected_file

  output:
    stdout()

  script:
    """
    diff ${output_file} ${expected_file} \
      && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}


workflow checker {
  take:
    tumour_bam
    tumour_bai
    normal_bam
    normal_bai
    fasta_file
    fasta_fai
    battenberg_ref_dir
    expected_output

  main:
    battenberg(
      tumour_bam,
      tumour_bai,
      normal_bam,
      normal_bai,
      fasta_file,
      fasta_fai,
      battenberg_ref_dir
    )

    file_smart_diff(
      battenberg.out.output_file,
      expected_output
    )
}


workflow {
  checker(
    file(params.tumour_bam),
    Channel.fromPath(getSecondaryFiles(params.tumour_bam,['{b,cr}ai']), checkIfExists: true).collect(),
    file(params.normal_bam),
    Channel.fromPath(getSecondaryFiles(params.normal_bam,['{b,cr}ai']), checkIfExists: true).collect(),
    file(params.fasta_file),
    Channel.fromPath(getSecondaryFiles(params.fasta_file,['fai']), checkIfExists: true).collect(),
    file(params.battenberg_ref_dir),
    file(params.expected_output)
  )
}
