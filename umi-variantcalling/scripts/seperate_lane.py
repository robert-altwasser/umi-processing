### code to seperate the variantcalls by lane
import pandas as pd
import numpy as np

variantcalls_path = "/home/altwassr/ablage/P1823/filter/variantcalls_all.csv"
samples_sheet_path = "/home/altwassr/projekte/sample_sheets/csv/SampleSheet_P1823.csv"

## read excel file variantcalls_path in python with pandas
samples_lane = pd.read_csv(samples_sheet_path, sep=",")

calls = pd.read_csv(variantcalls_path, sep="\t")

##find row with "Lane" in data frame samples_lane
lane_index = int(np.where(samples_lane.iloc[:,0] == "Lane")[0])
samples_lanes = samples_lane.iloc[lane_index + 1:,:] 
samples_lanes.columns = samples_lane.iloc[lane_index,:]

lanes = list(set(samples_lanes["Lane"]))

for lane in lanes:
    samples = set(samples_lanes.Sample_ID[samples_lanes["Lane"] == lane])
    temp = calls[calls["Sample"].isin(samples)]
    print(samples - set(temp["Sample"]))
    
    filename = "/home/altwassr/ablage/P1823/filter/variantcalls_all.csv".removesuffix(".csv")
    temp.to_csv(filename + "_" + lane + ".csv")
