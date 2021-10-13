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

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/

nextflow.enable.dsl = 2
version = '0.1.0.1'

// universal params
params.publish_dir = ""
params.container = ""
params.container_registry = ""
params.container_version = ""

// tool specific parmas go here, add / change as needed
params.expected_output = ""

params.cleanup = true

params.ref_genome_build = 'hg38'  // GRCh38
params.ref_genome_fa = ""
params.tumour_aln_seq = "NO_FILE1"
params.normal_aln_seq = "NO_FILE2"
params.tumour_id = ""

params.donor_sex = "female"  // or "male"
params.gcwiggle = ""
params.dbsnp_file = ""
params.is_test = false  // must be explictly set to true when run as test

// song/score download/upload
params.max_retries = 3
params.first_retry_wait_time = 10
params.song_url = ""
params.score_url = ""
params.api_token = ""

params.download = [:]

// song/score download
download_params = [
    'cpus': params.cpus,
    'mem': params.mem,
    'max_retries': params.max_retries,
    'first_retry_wait_time': params.first_retry_wait_time,
    'song_url': params.song_url,
    'score_url': params.score_url,
    'api_token': params.api_token,
    *:(params.download ?: [:])
]

include { ArgoSvCnvCalling } from '../main'
include { getSecondaryFiles; getBwaSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main.nf' params([*:params, 'cleanup': false])


process file_smart_diff {
  input:
    path output_file
    path expected_file

  output:
    stdout()

  script:
    """
    # Note: this is only for demo purpose, please write your own 'diff' according to your own needs.
    # in this example, we need to remove date field before comparison eg, <div id="header_filename">Tue 19 Jan 2021<br/>test_rg_3.bam</div>
    # sed -e 's#"header_filename">.*<br/>test_rg_3.bam#"header_filename"><br/>test_rg_3.bam</div>#'

    cat ${output_file[0]} \
      | sed -e 's#"header_filename">.*<br/>#"header_filename"><br/>#' > normalized_output

    ([[ '${expected_file}' == *.gz ]] && gunzip -c ${expected_file} || cat ${expected_file}) \
      | sed -e 's#"header_filename">.*<br/>#"header_filename"><br/>#' > normalized_expected

    diff normalized_output normalized_expected \
      && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}


workflow checker {
  take:
    study_id
    tumour_aln_analysis_id
    normal_aln_analysis_id
    ref_genome_fa
    ref_genome_gz_secondary_files
    tumour_aln_seq
    tumour_aln_seq_idx
    normal_aln_seq
    normal_aln_seq_idx
    gcwiggle
    dbsnp_file
    expected_output

  main:
    ArgoSvCnvCalling(
      study_id,
      tumour_aln_analysis_id,
      normal_aln_analysis_id,
      ref_genome_fa,
      ref_genome_gz_secondary_files,
      tumour_aln_seq,
      tumour_aln_seq_idx,
      normal_aln_seq,
      normal_aln_seq_idx,
      gcwiggle,
      dbsnp_file
    )

    /*
    file_smart_diff(
      ArgoSvCnvCalling.out.output_file,
      expected_output
    )
    */
}


workflow {
  checker(
    params.study_id,
    params.tumour_aln_analysis_id,
    params.normal_aln_analysis_id,
    file(params.ref_genome_fa),
    Channel.fromPath(getSecondaryFiles(params.ref_genome_fa, ['gzi'])).concat(
      Channel.fromPath(getBwaSecondaryFiles(params.ref_genome_fa))
    ).collect(),
    file(params.tumour_aln_seq),
    Channel.fromPath(getSecondaryFiles(params.tumour_aln_seq, ['bai', 'crai'])).collect(),
    file(params.normal_aln_seq),
    Channel.fromPath(getSecondaryFiles(params.normal_aln_seq, ['bai', 'crai'])).collect(),
    file(params.gcwiggle),
    file(params.dbsnp_file),
    file(params.expected_output)
  )
}
