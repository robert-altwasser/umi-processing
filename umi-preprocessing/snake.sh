#!/bin/bash

#SBATCH --job-name=preprocessing
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --output=/fast/users/altwassr_c/scratch/slurm_logs/%x.%j.out
#SBATCH --error=/fast/users/altwassr_c/scratch/slurm_logs/%x.%j.err

echo 'Start'
snakemake \
    --nt \
    --jobs 80 \
    --keep-going \
    --restart-times 1 \
    --cluster-config ~/work/umi-testing/umi-demultiplex/cluster/cluster_config.yaml \
    --profile=cubi-v1 \
    --reason \
    --printshellcmds \
    --use-conda --rerun-incomplete --conda-prefix=/fast/users/altwassr_c/work/conda-envs/
echo 'Finished'

