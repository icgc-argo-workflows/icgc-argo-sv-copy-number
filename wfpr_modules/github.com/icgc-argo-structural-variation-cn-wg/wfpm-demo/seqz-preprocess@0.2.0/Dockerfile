FROM continuumio/miniconda3:4.8.2
# newer version results in conflicts.

RUN apt-get update \
    && apt-get install -y procps \
           
    && /opt/conda/bin/conda install --yes -c bioconda samtools=1.9 tabix \
    && /opt/conda/bin/conda install --yes -c bioconda sequenza-utils=3.0.0

USER sequenza
WORKDIR /home/sequenza

CMD ["/bin/bash"]