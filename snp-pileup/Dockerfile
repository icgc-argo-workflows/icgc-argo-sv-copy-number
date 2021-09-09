FROM continuumio/miniconda3:4.9.2

LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
