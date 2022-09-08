#!/bin/bash

#SBATCH --job-name=preprocessing
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --output=/fast/users/altwassr_c/scratch/slurm_logs/%x.%j.out
#SBATCH --error=/fast/users/altwassr_c/scratch/slurm_logs/%x.%j.err

snakemake \
    --nt \
    --jobs 60 \
    --restart-times 0 \
    --cluster-config ~/work/umi-data-processing/config/cluster_config.yaml \
    --profile=cubi-v1 \
    --use-conda \
    -w 10 \
    --until multiqc_reads \
    --printshellcmds \
    --rerun-incomplete \
    --scheduler greedy \
    --conda-prefix=/fast/users/altwassr_c/work/conda-envs/ 
#    --reason \

    # --verbose \
    # --keep-going \
