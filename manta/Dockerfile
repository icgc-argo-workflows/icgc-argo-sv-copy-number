FROM quay.io/biocontainers/manta:1.6.0--h9ee0642_1

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/icgc-argo-sv-copy-number

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
