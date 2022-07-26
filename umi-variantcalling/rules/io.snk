import pandas as pd
import os
import re

def get_anno_params(_):
    '''
    helper function to create full annovar parameters from input_output[1]
    '''

    # get the full path to humandb
    humandb = config['annovar']['path_to_humandb']
    # humandb = os.path.join(config['paths']['mystatic'], config['annovar']['path_to_humandb'])
    # get the available anno files
    file_list = list(os.walk(humandb))[0][-1]
    # reduce anno files to the files compatible with genome build version
    build = config['annovar']['build']
    build_files = []
    for file in file_list:
        if build in file:
            build_files.append(file)

    # filter the anno protocol for the available files for that genome build        
    anno_refs = config['annovar']['annofiles']
    anno_list = []
    missing_list = []
    for anno in anno_refs:
        for file in build_files:
            if anno in file:
                anno_list.append(anno)
                break
        # if anno has not been found in file during for-loop
        else:
            missing_list.append(anno)

    # create the protocol string
    protocol = ','.join(anno_list)
    # print(f"{' '.join(missing_list)} not found for {build}! Doing without.. ")
    # create the operation string 'g,r,f,f,f,f' assuming all but the first three dbs (ref, cytoBand, superDups) in config to be filter-based
    operation_list = []
    for anno in anno_list:
        if anno == "refGene":
            operation_list.append('g')
        elif anno in ['cytoBand', 'genomicSuperDups']:
            operation_list.append('r')
        else:
            operation_list.append('f')
    operation = ','.join(operation_list)

    options = f'{humandb}/ -buildver {build} -remove -protocol {protocol} -operation {operation} -nastring "." -otherinfo'
    return options


#####################################

def static_path(file):
    '''
    returns the absolute path when given relative to static folder
    '''

    return os.path.join(config['paths']['mystatic'], file)
