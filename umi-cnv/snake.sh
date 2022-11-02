#!/bin/bash

snakemake \
    --snakefile Snakemake \
    --nt \
    --jobs 100 \
    --cluster-config ~/work/umi-data-processing/config/cluster_config.yaml \
    --profile=cubi-v1 \
    --restart-times 0 \
    --keep-going \
    --rerun-incomplete \
    --use-conda --conda-prefix=/fast/users/altwassr_c/work/conda-envs/
# --touch \
# --skip-script-cleanup \
# --reason \

