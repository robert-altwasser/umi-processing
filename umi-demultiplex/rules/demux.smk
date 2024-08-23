rule basecalls_to_fastq:
     input:
         basecalls=config["illumina"]["basecall_dir"],
         SampleSheet=config["general"]["SampleSheet"]
     output:
          flag = touch("logs/demux/done.txt")
     params:
         rstructure=config["illumina"]["readstructure"],
     threads: 30
     resources:
         mem="400G",
         mem_mb="400G",
         time="24:00:00"
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
                    --use-bases-mask {params.rstructure} \
                    --create-fastq-for-index-reads
         """

def get_fq(wildcards):
    # code that returns a list of fastq files  based on *wildcards.sample* e.g.
    return sorted(glob.glob("reads/" + wildcards.sample + '_S*.fastq.gz'))

        #fastq=get_fq,
rule fastq_to_bam:
    input:
        flag = "logs/demux/done.txt",
        fastq=get_fq
    output:
        "unmapped/{sample}.unmapped.bam"
    params:
         sampleName = "{sample}",
         readstructure = config["fgbio"]["readstructure"]
    log:
        "logs/fgbio/{sample}.log"
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
