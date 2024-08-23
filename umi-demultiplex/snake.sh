#!/bin/bash

#SBATCH --job-name=demux
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --output=/data/cephfs-1/work/projects/damm-belove/scratch/A4314_reseq/slurm/demux-%x.%j.out
#SBATCH --error=/data/cephfs-1/work/projects/damm-belove/scratch/A4314_reseq/slurm/demux-%x.%j.err

echo 'Start'
snakemake \
    -r \
    --nt \
    --jobs 60 \
    --keep-going \
    --latency-wait 180 \
    --verbose \
    --restart-times 3 \
    --profile=cubi-v1 \
    --cluster-config=/data/cephfs-1/work/projects/damm-belove/pipelines/umi-processing/config/cluster_config.yaml \
    --use-conda -p --rerun-incomplete --conda-prefix=/data/cephfs-1/work/projects/damm-belove/scratch/A4314_reseq/envs
echo 'Finished'


    #--dry-run \
    # --restart-times 2 \
    # --reason \
