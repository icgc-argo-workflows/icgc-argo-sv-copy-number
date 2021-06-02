# Impute2 and R dependencies through Bioconductor
FROM csoriano/snptest:latest as snptest
FROM bioconductor/bioconductor_docker:RELEASE_3_12

LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number

RUN mkdir /tools/
ENV PATH="/tools:/tools/bin:${PATH}"
ENV LD_LIBRARY_PATH="/tools/lib:${LD_LIBRARY_PATH}"

# Impute2
COPY --from=snptest /usr/local/bin/impute2 /tools/bin/impute2

# HTSLIB
RUN cd /tmp && \
	wget https://github.com/samtools/htslib/releases/download/1.12/htslib-1.12.tar.bz2 && \
	tar -xvjf htslib-1.12.tar.bz2 && \
	cd htslib-1.12 && \
	./configure --prefix=/tools && \
	make && \
	make install && \
	cd / && \
	rm -r /tmp/htslib-1.12 && \
	rm /tmp/htslib-1.12.tar.bz2

# AlleleCounter
RUN git clone https://github.com/cancerit/alleleCount.git /tmp/alleleCount && \
	cd /tmp/alleleCount && \
	./setup.sh /tools && \
	cd / && \
	rm -r /tmp/alleleCount


# R package dependencies
RUN R -e "devtools::install_github('Crick-CancerGenomics/ascat/ASCAT@v2.5.2')"

RUN R -e "BiocManager::install(c('readr', 'doParallel', 'ggplot2', 'RColorBrewer', 'gridExtra', 'gtools', 'foreach', 'optparse'))"

RUN git clone https://github.com/kateeasoncrukci/BattenbergHG38.git

RUN R -e "install.packages('BattenbergHG38/BattenbergHG38_2.2.10.tar.gz', repos = NULL, type = 'source')"

# Battenberg running script
COPY run_battenberg.R /tools/
RUN chmod +x /tools/run_battenberg.R

CMD ["/tools/run_battenberg.R"]