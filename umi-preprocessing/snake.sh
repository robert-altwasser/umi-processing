#!/bin/bash

#SBATCH --job-name=preprocessing
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --output=/data/gpfs-1/users/cofu10_c/scratch/A4314_reseq/slurm_logs/%x.%j.out
#SBATCH --error=/data/gpfs-1/users/cofu10_c/scratch/A4314_reseq/slurm_logs/%x.%j.err

snakemake \
    --nt \
    --jobs 250 \
    --restart-times 3 \
    --cluster-config /data/gpfs-1/users/cofu10_c/work/pipelines/umi-processing/config/cluster_config.yaml \
    --profile=cubi-v1 \
    --use-conda \
    --conda-frontend mamba \
    --printshellcmds \
    --rerun-incomplete \
    --scheduler greedy \
    --keep-going \
    --conda-prefix=/data/gpfs-1/users/cofu10_c/scratch/A3414_reseq/envs \
    --reason \
    --verbose \
    --keep-going \
