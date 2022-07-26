rule basecalls_to_fastq:
     input:
         basecalls=config["illumina"]["basecall_dir"],
         SampleSheet=config["general"]["SampleSheet"]
     output:
          basecall_done="logs/demux/done.txt",
          results=dynamic("reads/{sample}_S{part}.fastq.gz"
     params:
         rstructure=config["illumina"]["readstructure"],
     threads: 30
     resources:
         mem="70G",
         mem_mb="70G",
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
                    --create-fastq-for-index-reads \
                    --use-bases-mask {params.rstructure}
        touch {output.basecall_done}
         """

def get_fq(wildcards):
    # code that returns a list of fastq files  based on *wildcards.sample* e.g.
    return sorted(glob.glob("reads/" + wildcards.sample + '_S*.fastq.gz'))

        #fastq=get_fq,
rule fastq_to_bam:
    input:
        fastq=dynamic("reads/{sample}_S{part}.fastq.gz")
        basecall_done="logs/demux/done.txt"
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
