FROM continuumio/miniconda3:4.9.2

# filled by wfpm
LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number

# add ps (required by nextflow)
RUN apt-get --allow-releaseinfo-change update  && \
    apt-get install -y procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install facets and dependencies
RUN /opt/conda/bin/conda install --yes -c conda-forge r-base=4.0.3 r-optparse r-rcolorbrewer r-plyr r-dplyr r-tidyr r-stringr r-magrittr r-foreach
RUN /opt/conda/bin/conda install --yes -c bioconda r-facets=0.6.1 snp-pileup=0.6.1

# Add main wrapper:
RUN mkdir -p /tools
ENV PATH="/tools:${PATH}"
COPY facetsRun.R /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
