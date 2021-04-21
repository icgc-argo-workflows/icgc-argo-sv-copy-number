# ICGC-ARGO SV and CN Working Group Pipeline

## Work In Progress 🚧

Nextflow pipeline for the SV and CN Working Group of ICGC-ARGO.

## Adding Tools

### Requirements
* Python >= 3.6
* pip >= 20.0
* Nextflow >= 20.10
* Docker >= 19.0

To add a tool/step to the pipeline, clone this repository locally and [install wfpm](https://wfpm.readthedocs.io/en/latest/README.html#installation). 
Then, create a new tool in wfpm.
```bash
wfpm new tool <name-of-tool>
```

Keeping everything standard except for the version (set to 0.2.0). This will create a new branch in the repository `<name-of-tool>@0.2.0` and initialize a folder with template tool files.