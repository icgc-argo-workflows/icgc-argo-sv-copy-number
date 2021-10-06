## use ubuntu minimal base image
FROM ubuntu:focal

LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number

# install dependencies
RUN apt-get clean && \
	apt-get update -y && \
	apt-get install --no-install-recommends -y \
	python3-minimal \
	git \
	build-essential \
	zlib1g-dev \
	libbz2-dev \
	liblzma-dev \
	procps

RUN git config --global http.sslVerify false && \
	# install svaba from github repository
	git clone --recursive https://github.com/walaj/svaba --branch 1.1.0 && \
	cd svaba && \
	./configure && \
	make && \
	make install && \
	cp bin/svaba /usr/bin/

ENTRYPOINT ["svaba"]
