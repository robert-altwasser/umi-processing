#!/bin/bash

#SBATCH --job-name=variantcalling
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=144:00:00
#SBATCH --mem-per-cpu=24000M
#SBATCH --output=/fast/users/altwassr_c/scratch/slurm_logs/%x.%j.out
#SBATCH --error=/fast/users/altwassr_c/scratch/slurm_logs/%x.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=robert.altwasser@charite.de

snakemake --unlock

snakemake \
    --nt \
    --jobs 100 \
    --cluster-config ~/work/umi-data-processing/config/cluster_config.yaml \
    --profile=cubi-v1 \
    --restart-times 0 \
    --keep-going \
    --rerun-triggers mtime \
    --rerun-incomplete \
    --use-conda --conda-prefix=/fast/users/altwassr_c/work/conda-envs/


# --touch \
# --skip-script-cleanup \
# --reason \
    # --printshellcmds \

# --until annovar \
