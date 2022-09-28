#!/bin/bash

#SBATCH --job-name=demux
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --output=/fast/users/altwassr_c/scratch/slurm_logs/demux-%x.%j.out
#SBATCH --error=/fast/users/altwassr_c/scratch/slurm_logs/demux-%x.%j.err

echo 'Start'
snakemake \
    -r \
    --nt \
    --jobs 40 \
    --keep-going \
    --restart-times 2 \
    --profile=cubi-v1 \
    --cluster-config ~/work/umi-data-processing/config/cluster_config.yaml \
    --use-conda -p --rerun-incomplete --conda-prefix=/fast/users/altwassr_c/work/conda-envs/
echo 'Finished'


    #--dry-run \
    # --restart-times 2 \
    # --reason \
