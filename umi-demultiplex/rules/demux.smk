rule extract_barcodes:
    input:
        basecalls=config["illumina"]["basecall_dir"],
        bfile=expand(config["general"]["barcode_file_prefix"] + "{lane}.csv", lane=LANE)
    output:
        expand("metrices/barcode_metrices{lane}.txt", lane=LANE)
    params:
        rstructure=config["illumina"]["readstructure"]
        lane=expand({lane}, lane=LANE)
    log:
        expand("logs/picard/ExtractIlluminaBarcodes{lane}.txt", lane=LANE)
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
        metrices="metrices/barcode_metrices.txt",
        lparams=config["general"]["library_file"]
    output:
        expand("unmapped/{sample}.unmapped.bam", sample=SAMPLES)
    params:
        lane=config["illumina"]["lane"],
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
        MAX_RECORDS_IN_RAM={params.mrecords} MAX_READS_IN_RAM_PER_TILE={params.mrecords} &> {log}
        rm -r tmp 
        """
