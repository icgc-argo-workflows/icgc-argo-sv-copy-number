# R dependencies through Bioconductor
FROM bioconductor/bioconductor_docker:RELEASE_3_12

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/icgc-argo-sv-copy-number

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

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

# Beagle5
RUN cd /usr/local/bin && \
	wget https://faculty.washington.edu/browning/beagle/beagle.28Jun21.220.jar && \
	chmod a=rx /usr/local/bin/beagle.28Jun21.220.jar && \
	cd /

RUN cpan LEONT/Const-Fast-0.014.tar.gz
RUN cpan PLICEASE/File-Which-1.27.tar.gz

# R package dependencies
RUN R -e "devtools::install_github('Crick-CancerGenomics/ascat/ASCAT@v2.5.2')"

RUN R -e "BiocManager::install(c('readr', 'doParallel', 'ggplot2', 'RColorBrewer', 'gridExtra', 'gtools', 'foreach', 'optparse', 'igordot/copynumber@b404a4d6e287b03d6841afaac1f5367cb5138e24', 'VariantAnnotation'))"

#RUN R -q -e "devtools::install_github('Wedge-Oxford/battenberg@v2.2.10')"

# Modified Battenberg installation
COPY battenberg_package /tmp/battenberg_package
RUN cd /tmp/battenberg_package && \
	R CMD build battenberg-2.2.10.1 && \
	R CMD INSTALL Battenberg_2.2.10.1.tar.gz && \
	cd / && \
	rm -r /tmp/battenberg_package

# Battenberg running script
COPY run_battenberg.R /usr/local/bin
RUN chmod u+x /usr/local/bin/run_battenberg.R

CMD ["run_battenberg.R"]
