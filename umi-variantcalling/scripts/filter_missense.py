######################################################
### Script that filters variant calls by comparing 
### the reads of the reference "TR1" and the variant
### "TR2" with the read depth.
######################################################
import pandas as pd
import os
from script_utils import show_output


# ############## SNAKEMAKE ################################
w = snakemake.wildcards
config = snakemake.config
params = snakemake.params
MINSIM = params.min_sim

i = snakemake.input

path_to_varcalls = "/home/altwassr/projekte/beLove/results/test.csv"

var_calls = pd.read_csv(path_to_varcalls,
                        sep = "\t")

tvaf = var_calls["TVAF"]
depth_tot = var_calls["readDepth"]
depth_ref = var_calls["TR1"]
depth_alt = var_calls["TR2"]
N_errors = depth_tot - depth_ref - depth_alt
N_vaf = N_errors / depth_tot

### TVAF has to be more that 0.5 percent-points ahead of N_vaf
passed = abs(tvaf - N_vaf) > 0.05
### "rescuing" low "TVAF"s, where there are actually no "N"s
### this can happen if the TVAF is already below 0.005
passed[N_vaf == 0] = True
