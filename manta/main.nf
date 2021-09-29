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
    Alvaro Ferriz
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number.manta'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir

params.help = null

// tool specific parmas go here, add / change as needed
params.normalBam = ""
params.tumorBam = ""
params.referenceFasta = ""

// These are not neccesary, the function will take them automatically using the name of the main file and adding the proper extension
// They remain here in case there is a need to input them manually
params.normalBai = ""
params.tumorBai = ""
params.referenceFai = ""
params.runDir = ""
params.available_memory = ""


include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main.nf'


def helpMessage() {
    log.info"""

USAGE

Usage: configManta.py [options]

Version: 1.6.0

This script configures the Manta SV analysis pipeline.
You must specify a BAM or CRAM file for at least one sample.

Configuration will produce a workflow run script which
can execute the workflow on a single node or through
sge and resume any interrupted execution.

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  --config=FILE         provide a configuration file to override defaults in
                        global config file (/gpfs/scratch/bsc05/bsc05017/MOUNT
                        /apps/manta-1.6.0.centos6_x86_64/bin/configManta.py.in
                        i)
  --allHelp             show all extended/hidden options

  Workflow options:
    --bam=FILE, --normalBam=FILE
                        Normal sample BAM or CRAM file. May be specified more
                        than once, multiple inputs will be treated as each BAM
                        file representing a different sample. [optional] (no
                        default)
    --tumorBam=FILE, --tumourBam=FILE
                        Tumor sample BAM or CRAM file. Only up to one tumor
                        bam file accepted. [optional] (no default)
    --exome             Set options for WES input: turn off depth filters
    --rna               Set options for RNA-Seq input. Must specify exactly
                        one bam input file
    --unstrandedRNA     Set if RNA-Seq input is unstranded: Allows splice-
                        junctions on either strand
    --referenceFasta=FILE
                        samtools-indexed reference fasta file [required]
    --runDir=DIR        Name of directory to be created where all workflow
                        scripts and output will be written. Each analysis
                        requires a separate directory. (default:
                        MantaWorkflow)
    --callRegions=FILE  Optionally provide a bgzip-compressed/tabix-indexed
                        BED file containing the set of regions to call. No VCF
                        output will be provided outside of these regions. The
                        full genome will still be used to estimate statistics
                        from the input (such as expected fragment size
                        distribution). Only one BED file may be specified.
                        (default: call the entire genome)

  Extended options:
    These options are either unlikely to be reset after initial site
    configuration or only of interest for workflow development/debugging.
    They will not be printed here if a default exists unless --allHelp is
    specified

    --existingAlignStatsFile=FILE
                        Pre-calculated alignment statistics file. Skips
                        alignment stats calculation.
    --useExistingChromDepths
                        Use pre-calculated chromosome depths.
    --retainTempFiles   Keep all temporary files (for workflow debugging)
    --generateEvidenceBam
                        Generate a bam of supporting reads for all SVs
    --outputContig      Output assembled contig sequences in VCF file
    --scanSizeMb=INT    Maximum sequence region size (in megabases) scanned by
                        each task during SV Locus graph generation. (default:
                        12)
    --region=REGION     Limit the analysis to a region of the genome for
                        debugging purposes. If this argument is provided
                        multiple times all specified regions will be analyzed
                        together. All regions must be non-overlapping to get a
                        meaningful result. Examples: '--region chr20' (whole
                        chromosome), '--region chr2:100-2000 --region
                        chr3:2500-3000' (two regions)'. If this option is
                        specified (one or more times) together with the
                        --callRegions BED file, then all region arguments will
                        be intersected with the callRegions BED track.
    --callMemMb=INT     Set default task memory requirement (in megabytes) for
                        common tasks. This may benefit an analysis of unusual
                        depth, chimera rate, etc.. 'Common' tasks refers to
                        most compute intensive scatter-phase tasks of graph
                        creation and candidate generation.
    """.stripIndent()
}

if (params.help) exit 0, helpMessage()



process manta {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path normalBam
    path tumorBam
    path referenceFasta
    path normalBai
    path tumorBai
    path referenceFai
    val available_memory

  output:  // output, make update as needed
    path "output_dir", emit: output_file

  script:
    // add and initialize variables here as needed

    """

    mkdir -p output_dir

    echo "RUNNING VARIANT CALLER"

    configManta.py \
    --normalBam ${normalBam} \
    --tumorBam ${tumorBam} \
    --referenceFasta ${referenceFasta} \
    --runDir output_dir 
    
    if [ -z ${available_memory} ]
    then
      output_dir/runWorkflow.py
    else
      output_dir/runWorkflow.py --memGb ${available_memory} 
    fi
    """


}



// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  manta(
    file(params.normalBam),
    file(params.tumorBam),  
    file(params.referenceFasta),
    Channel.fromPath(getSecondaryFiles(params.normalBam,['bai']), checkIfExists: true).collect(),
    Channel.fromPath(getSecondaryFiles(params.tumorBam,['bai']), checkIfExists: true).collect(),
    Channel.fromPath(getSecondaryFiles(params.referenceFasta,['fai']), checkIfExists: true).collect(),
    params.available_memory  
  )
}