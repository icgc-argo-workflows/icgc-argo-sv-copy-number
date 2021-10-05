#!/usr/bin/env nextflow

/*
 This is an example process as a local module. Using local module is optional, in general
 is discouraged. A process can pentially be reused in different workflows should be developed
 in an independent package, so that it can be imported by anyone into any workflow.
*/

nextflow.enable.dsl = 2

params.summary = ""
params.cncf = ""
params.plot = ""
params.publish_dir = "facets-wf_out"


process makeTar {
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  input:
    path summary
    path cncf
    path plot

  output:
    path "*.tar.gz", emit: output_tar

  shell:
    '''
# initiate json report file
echo foo > facets_metrics.json

# make tar_content.json
echo bar > tar_content.json

# tar the results
tar -czf $(basename -s .out !{summary}).tgz hs_metrics.json tar_content.json !{cncf} !{plot}
    '''
}
