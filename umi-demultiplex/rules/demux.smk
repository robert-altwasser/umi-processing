rule basecalls_to_fastq:
     input:
         basecalls=config["illumina"]["basecall_dir"],
         SampleSheet=config["general"]["SampleSheet"]
     output:
          # "logs/demux/done.txt"
          expand("reads/{sample}._S*.fastq.gz", sample=SAMPLES)
     params:
         rstructure=config["illumina"]["readstructure"],
     threads: 30
     resources:
         mem="70G",
         mem_mb="70G",
         time="4:00:00"
     log:
         "logs/bcl2fastq/bcl2fastq.txt"
     shell:
         """
         bcl2fastq \
                    --input-dir {input.basecalls} \
                    --runfolder-dir {input.basecalls}/../../../ \
                    --output-dir reads \
                    --sample-sheet {input.SampleSheet} \
                    --barcode-mismatches 1 \
                    --loading-threads 6 \
                    --writing-threads 6 \
                    --processing-threads 30 \
                    --ignore-missing-bcl \
                    --ignore-missing-filter \
                    --mask-short-adapter-reads 0 \
                    --create-fastq-for-index-reads \
                    --use-bases-mask {params.rstructure}
         """

def get_fq(wildcards):
    # code that returns a list of fastq files  based on *wildcards.sample* e.g.
    return sorted(glob.glob("reads/" + wildcards.sample + '_S*.fastq.gz'))

rule fastq_to_bam:
    input:
        fastq=get_fq,
        # basecall_done="logs/demux/done.txt"
    output:
        "unmapped/{sample}.unmapped.bam"
        # temp("unmapped/unsorted/{sample}.unmapped_unsorted.bam")
    params:
         sampleName = "{sample}",
         readstructure = config["fgbio"]["readstructure"]
    log:
        "logs/fgbio/FastqToBam_{sample}.log"
    resources:
        mem="70G",
        mem_mb="70G",
        time="5:00:00"
    shell:
        """
        fgbio FastqToBam \
        --input {input.fastq} \
        --read-structures {params.readstructure} \
        --output {output} \
        --sort true \
        --sample {params.sampleName} \
        --library=illumina &> {log}
        """

rule sort_sam:
    input:
        "unmapped/unsorted/{sample}.unmapped_unsorted.bam"
    output:
        "unmapped/{sample}.unmapped.bam"
    log:
        "logs/picard/sort_sam_{sample}.log"
    resources:
        mem="10G",
        mem_mb="10G",
        time="5:00:00"
    shell:
        """
        picard SortSam \
        I={input} \
        O={output} \
        SORT_ORDER=queryname &> {log}
        """

# rule basecalls_to_sam:
#     input:
#         basecalls=config["illumina"]["basecall_dir"],
#         metrices="metrices/barcode_metrices{lane}.txt",
#         lparams=config["general"]["library_file_prefix"]+ "{lane}.csv"
#     output:
#         "logs/picard/IlluminaBasecallsToSam_done{lane}.log"
#     params:
#         lane="{lane}",
#         rstructure=config["illumina"]["readstructure"],
#         runbarcode=config["illumina"]["runbarcode"],
#         musage=config["picard"]["memoryusage"],
#         mrecords= "500000",
#         temp_dir=config["general"]["tmp_dir"],
#     threads: 1
#     resources:
#         mem_mb="16G",
#         time="20:00:00"
#     log:
#         "logs/picard/IlluminaBasecallsToSam_{lane}.log"
#     shell:
#         r"""
#         picard {params.musage} IlluminaBasecallsToSam \
#         B={input.basecalls} \
#         L={params.lane} \
#         RS={params.rstructure} \
#         RUN_BARCODE={params.runbarcode} \
#         LIBRARY_PARAMS={input.lparams} \
#         SEQUENCING_CENTER=CHARITE \
#         TMP_DIR={params.temp_dir} \
#         MAX_RECORDS_IN_RAM={params.mrecords} \
#         MAX_READS_IN_RAM_PER_TILE={params.mrecords} &> {log}
#         touch logs/picard/IlluminaBasecallsToSam_done{params.lane}.log
#         """

# rule extract_barcodes:
#     input:
#         basecalls=config["illumina"]["basecall_dir"],
#         bfile=config["general"]["barcode_file_prefix"] + "{lane}.csv"
#     output:
#         "metrices/barcode_metrices{lane}.txt"
#     params:
#         rstructure=config["illumina"]["readstructure"],
#         lane="{lane}",
#         musage=config["picard"]["memoryusage"],
#         temp_dir=config["general"]["tmp_dir"],
#         cores=8 
#     threads: 8
#     resources:
#         mem="70G",
#         mem_mb="70G",
#         time="5:00:00"
#     log:
#         "logs/picard/ExtractIlluminaBarcodes{lane}.txt"
#     shell:
#         r"""
#         picard {params.musage} ExtractIlluminaBarcodes \
#         -B {input.basecalls} \
#         -L {params.lane} \
#         --NUM_PROCESSORS {params.cores} \
#         -M {output} \
#         -TMP_DIR {params.temp_dir} \
#         -BARCODE_FILE {input.bfile} \
#         -RS {params.rstructure} &> {log}
#         """
