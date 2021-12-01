#!/bin/bash
#SBATCH --job-name=variantcalling
#SBATCH --output=log.txt
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --error="../slurm-%A_%a.out"
#SBATCH --output="../slurm-%j.out"
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=2000M


echo 'Start'
snakemake --drmaa " -t 4:00 -p medium --mem-per-cpu=15048 --ntasks-per-node=5" --jobs 40 --nt -r --use-conda -p --rerun-incomplete  --conda-prefix=/fast/users/altwassr_c/work/conda-envs/
# snakemake --drmaa " -t 4:00 -p medium --mem-per-cpu=15048 --ntasks-per-node=5" --jobs 40 --nt -r --use-conda -p --rerun-incomplete --until vardict
echo 'Finished'

# snakemake --forceall --rulegraph | dot -Tpdf > snakemake_rules.pdf
