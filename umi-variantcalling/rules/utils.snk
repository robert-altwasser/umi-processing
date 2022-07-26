from subprocess import Popen, PIPE, DEVNULL
from io import StringIO
import pandas as pd
import os


# ############ FILTER_BAM UTILS ########################################################
def reduce_regions(df, padding):
    '''
    takes a mutation list and returns a region list using padding
    overlapping regions are reduced to one using the gap strategy
    '''

    df = df.sort_values('Start')
    df['Start'] = df['Start'] - padding
    df['End'] = df['End'] + padding
    # find the break points
    # if Start is greater than previous End (using shift), this is a gap --> df['gap'] = 1
    df['gap'] = df['Start'].gt(df['End'].shift()).astype('int')
    # id different reads according to gap
    # cumulative sum does not increase at df['gap'] == 0 and so these consecutive stretches are grouped together
    df['gap'] = df['gap'].cumsum()
    # groupby the coverage break group and condense individual coverage islands
    # agg has to contain the neccessary shared columns TransLength because it is needed for coverage computation
    new_df = df.groupby('gap').agg({'Start': 'min', 'End':'max'})
    new_df = new_df
    return new_df.reset_index('gap').drop(columns='gap')


def mut2bed(mut_file, padding, bed_file):
    # check for filter_bam folder (using general declaration for easy folder name changing)
    folder = os.path.split(bed_file)[0]
    if not os.path.isdir(folder):
        os.makedirs(folder)

    # read the anno_file
    anno_df = pd.read_csv(mut_file, sep='\t').sort_values(['Chr', 'Start']).iloc[:,:5]
    if not len(anno_df.index):
        anno_df.to_csv(bed_file, index=False, sep='\t', header=False)
        return bed_file

    # get the bedfie with padded and collapsed regions
    bed_df = anno_df.groupby('Chr').apply(reduce_regions, padding)
    # remove Chr index
    bed_df = bed_df.reset_index().drop(columns='level_1')
    # write bed_df to file
    bed_df.to_csv(bed_file, index=False, sep='\t', header=False)
    return bed_file


def get_mut_bed(w, input):
    '''
    serves as a params function creating and returning the bed file for the samtools view
    '''
    conf = config['filter_bam']
    padding = conf['padding']
    bed_file = mut2bed(input.csv, padding, f"{conf['folder']}/{w.sample}_{w.tumor}-{w.normal}.bed")
    return bed_file