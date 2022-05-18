### increase memory to 10x the attempt
def myrule_mem(wildcards, attempt):
    mem = 50 * attempt
    return '%dG' % mem


rule basecalls_to_fastq:
     input:
         basecalls=config["illumina"]["basecall_dir"],
         SampleSheet=config["general"]["SampleSheet"]
     output:
          "logs/demux/done.txt"
          #expand("bcl2fastq/{sample}._S*.fastq.gz", sample=SAMPLES)
     params:
         rstructure=config["illumina"]["readstructure"],
     threads: 50
     resources:
         mem="70G",
         mem_mb="70G",
         time="5:00:00"
     log:
         "logs/bcl2fastq/bcl2fastq.txt"
     shell:
         """
         bcl2fastq \
         --input-dir {input.basecalls} \
                    --runfolder-dir {input.basecalls}/../../../ \
                    --output-dir bcl2fastq \
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
         touch {output}
         """

def get_fq(wildcards):
    # code that returns a list of fastq files  based on *wildcards.sample* e.g.
    return sorted(glob.glob("bcl2fastq/" + wildcards.sample + '_S*.fastq.gz'))

rule fastq_to_bam:
    input:
        fastq=get_fq,
        basecall_done="logs/demux/done.txt"
    output:
        temp("unmapped/unsorted/{sample}.unmapped_unsorted.bam")
    params:
         sampleName = "{sample}"
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
        --read-structures 8B 8B 148T 9M 148T \
        --output {output} \
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
