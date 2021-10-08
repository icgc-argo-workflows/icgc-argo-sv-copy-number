# Impute2 and R dependencies through Bioconductor
FROM csoriano/snptest:latest as snptest
FROM bioconductor/bioconductor_docker:RELEASE_3_12

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/icgc-argo-sv-copy-number

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# Impute2
COPY --from=snptest /usr/local/bin/impute2 /usr/local/bin/impute2

# HTSLIB
RUN cd /tmp && \
	wget https://github.com/samtools/htslib/releases/download/1.12/htslib-1.12.tar.bz2 && \
	tar -xvjf htslib-1.12.tar.bz2 && \
	cd htslib-1.12 && \
	./configure --prefix=/usr/local && \
	make && \
	make install && \
	cd / && \
	rm -r /tmp/htslib-1.12 && \
	rm /tmp/htslib-1.12.tar.bz2

# AlleleCounter
RUN git clone https://github.com/cancerit/alleleCount.git /tmp/alleleCount && \
	cd /tmp/alleleCount && \
	./setup.sh /usr/local && \
	cd / && \
	cp -r /tmp/alleleCount/perl/lib/* /usr/local/lib && \
	rm -r /tmp/alleleCount

RUN cpan LEONT/Const-Fast-0.014.tar.gz
RUN cpan PLICEASE/File-Which-1.27.tar.gz

# R package dependencies
RUN R -e "devtools::install_github('Crick-CancerGenomics/ascat/ASCAT@v2.5.2')"

RUN R -e "BiocManager::install(c('readr', 'doParallel', 'ggplot2', 'RColorBrewer', 'gridExtra', 'gtools', 'foreach', 'optparse'))"

RUN git clone https://github.com/kateeasoncrukci/BattenbergHG38.git

RUN R -e "install.packages('BattenbergHG38/BattenbergHG38_2.2.10.tar.gz', repos = NULL, type = 'source')"

# Battenberg running script
COPY run_battenberg.R /usr/local/bin
RUN chmod +x /usr/local/bin/run_battenberg.R

CMD ["run_battenberg.R"]