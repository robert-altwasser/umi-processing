### Method to return the lane for sample name
### REQUIRES: samples_lanes
def get_lane_for_sample(wildcards):
    return samples_lanes[wildcards.sample]

### Method to return the name of 'barcode_metrices' file for sample name
### REQUIRES: samples_lanes
def get_barcode_metric_for_sample(wildcards):
    return "metrices/barcode_metrices" + samples_lanes[wildcards.sample] + ".csv"

### Method to return the name of 'library_file' file for sample name
### REQUIRES: samples_lanes
def get_library_file_for_sample(wildcards):
    return library_file_prefix + samples_lanes[wildcards.sample] + ".csv"

rule extract_barcodes:
    input:
        basecalls=config["illumina"]["basecall_dir"],
        bfile=barcode_file_prefix + "{lane}.csv"
        bfile=get_barcode_file_for_sample
    output:
        "metrices/barcode_metrices{lane}.txt"
    params:
        rstructure=config["illumina"]["readstructure"]
        lane={lane}
    log:
        "logs/picard/ExtractIlluminaBarcodes{lane}.txt"
    shell:
        r"""
        mkdir -p metrices

        picard ExtractIlluminaBarcodes \
        B={input.basecalls} \
        L={params.lane} \
        M={output} \
        BARCODE_FILE={input.bfile} \
        RS={params.rstructure} &> {log}
        """


rule basecalls_to_sam:
    input:
        basecalls=config["illumina"]["basecall_dir"],
        metrices=get_barcode_metric_for_sample,
        lparams=get_library_file_for_sample
    output:
        expand("unmapped/{sample}.unmapped.bam", sample=SAMPLES)
    params:
        lane=get_lane_for_sample,
        rstructure=config["illumina"]["readstructure"],
        runbarcode=config["illumina"]["runbarcode"],
        musage=config["picard"]["memoryusage"],
        mrecords= "500000"
    log:
        "logs/picard/IlluminaBasecallsToSam.log"
    shell:
        r"""
        mkdir -p tmp
        picard {params.musage} IlluminaBasecallsToSam \
        B={input.basecalls} \
        L={params.lane} \
        RS={params.rstructure} \
        RUN_BARCODE={params.runbarcode} \
        LIBRARY_PARAMS={input.lparams} \
        SEQUENCING_CENTER=CHARITE \
        TMP_DIR=tmp/ \
        MAX_RECORDS_IN_RAM={params.mrecords} \
        MAX_READS_IN_RAM_PER_TILE={params.mrecords} &> {log}
        rm -r tmp
        """
