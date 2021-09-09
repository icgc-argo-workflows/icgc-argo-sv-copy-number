FROM continuumio/miniconda3:4.9.2

# filled by wfpm
LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/wfpm-demo

# add ps (required by nextflow)
RUN apt-get --allow-releaseinfo-change update  && \
    apt-get install -y procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# install snp-pileup
ENV PATH="/opt/conda/bin:${PATH}"
# have to use -c conda-forge (first) and install samtools>=1.10 otherwise samtools errors because of missing libcrypto.so.1.0.0)
RUN conda install --yes -c conda-forge -c bioconda snp-pileup=0.6.1 "samtools>=1.10"

# Add main wrapper:
RUN mkdir -p /tools
ENV PATH="/tools:${PATH}"
COPY main.sh /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
