#!/bin/bash

#SBATCH --job-name=preprocessing
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=336:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --output=/fast/users/altwassr_c/slurm_log/R-%x.%j.out
#SBATCH --error=/fast/users/altwassr_c/slurm_log/R-%x.%j.err

echo 'Start'
snakemake --drmaa " -t 336:00:00 -p medium --mem=200000 --mem-per-cpu=19048 --ntasks-per-node=10" -r --nt --jobs 40 --use-conda -p --rerun-incomplete --conda-prefix=/fast/users/altwassr_c/work/conda-envs/
# snakemake --drmaa " -t 10:00:00 -p medium --mem=200000 --mem-per-cpu=19048 --ntasks-per-node=10" -r --nt --jobs 40 --use-conda -p --rerun-incomplete --until basecalls_to_sam --conda-prefix=/fast/users/altwassr_c/work/conda-envs/
echo 'Finished'

