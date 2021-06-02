FROM quay.io/biocontainers/cancerit-allelecount:4.2.1--h41abebc_1 as acount
FROM csoriano/snptest:latest as snptest
FROM bioconductor/bioconductor_docker:RELEASE_3_12

LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number

COPY --from=acount /usr/local/bin/alleleCounter ./bin
COPY --from=snptest /usr/local/bin/impute2 ./bin

RUN mkdir /tools/

ENV PATH="/tools:${PATH}"

COPY run_battenberg.R /tools/
RUN chmod +x /tools/run_battenberg.R

RUN git clone https://github.com/kateeasoncrukci/BattenbergHG38.git

RUN R -e "devtools::install_github('Crick-CancerGenomics/ascat/ASCAT@v2.5.2')"

RUN R -e "BiocManager::install(c('readr', 'doParallel', 'ggplot2', 'RColorBrewer', 'gridExtra', 'gtools', 'foreach', 'optparse'))"

RUN R -e "install.packages('BattenbergHG38/BattenbergHG38_2.2.10.tar.gz', repos = NULL, type = 'source')"

CMD ["/tools/run_battenberg.R"]