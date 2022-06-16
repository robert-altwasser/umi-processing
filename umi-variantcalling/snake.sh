#!/bin/bash

# export SNAKEMAKE_SLURM_DEBUG=1

#SBATCH --job-name=variantcalling
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=144:00:00
#SBATCH --mem-per-cpu=24000M
#SBATCH --output=/fast/users/altwassr_c/scratch/slurm_logs/%x.%j.out
#SBATCH --error=/fast/users/altwassr_c/scratch/slurm_logs/%x.%j.err

echo 'Start'
snakemake \
    --nt \
    --jobs 60 \
    --restart-times 2 \
    --cluster-config ~/work/umi-testing/umi-demultiplex/cluster/cluster_config.yaml \
    --profile=cubi-v1 \
    --keep-going \
    --reason \
    --printshellcmds \
    --rerun-incomplete \
    --use-conda --conda-prefix=/fast/users/altwassr_c/work/conda-envs/
# --touch \
# --skip-script-cleanup \

# --until annovar \
echo 'Finished'
