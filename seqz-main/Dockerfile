FROM continuumio/miniconda3:4.8.2
# newer version results in conflicts.

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/icgc-argo-sv-copy-number

RUN apt-get --allow-releaseinfo-change update \
    && apt-get install -y procps \
    && /opt/conda/bin/conda install --yes -c bioconda r-sequenza=3.0.0 r-optparse \
    && git clone https://github.com/aroneklund/copynumber.git \
    && /opt/conda/bin/R CMD INSTALL copynumber

# add runSequenza.R and main.sh to /tools
RUN mkdir /tools
COPY runSequenza.R /tools/
COPY maketar.sh /tools/
ENV PATH="/tools:${PATH}"


ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]