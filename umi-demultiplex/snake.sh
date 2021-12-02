#!/bin/bash

#SBATCH --job-name=preprocessing
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --output=/fast/users/altwassr_c/slurm_log/R-%x.%j.out
#SBATCH --error=/fast/users/altwassr_c/slurm_log/R-%x.%j.err

echo 'Start'
snakemake --drmaa " -t 10:00:00 -p medium --mem=160000 --mem-per-cpu=15048 --ntasks-per-node=10" -r --nt --jobs 40 --use-conda -p --rerun-incomplete --until basecalls_to_sam --conda-prefix=/fast/users/altwassr_c/work/conda-envs/
# snakemake --drmaa " -t 10:00:00 -p medium --mem=160000 --mem-per-cpu=15048 --ntasks-per-node=10" -r --nt --jobs 40 --use-conda -p --rerun-incomplete --until map_reads1
#  snakemake --drmaa " -t 10:00:00 -p medium --mem=160000 --mem-per-cpu=15048 --ntasks-per-node=10" -r --nt --jobs 40 --use-conda -p --rerun-incomplete
echo 'Finished'

