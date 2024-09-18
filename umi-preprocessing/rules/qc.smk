rule get_fastqc_input:
    input:
        "unmapped/{sample}.unmapped.bam"
    output:
        read1=temp("reads/{sample}.R1.fastq"),
        read2=temp("reads/{sample}.R2.fastq")
    params:
        musage=config["picard"]["memoryusage"]
    log:
        "logs/reads/{sample}.samtofastq.log"
    threads:
        8
    resources:
        mem_mb="30G",
        time="01:00:00"
    shell:
        r"""
        picard {params.musage} SamToFastq I={input} F={output.read1} SECOND_END_FASTQ={output.read2} &> {log}
        """

rule fastqc:
    input:
        "reads/{sample}.{read}.fastq"
    output:
        html="qc/fastqc/{sample}.{read}.html",
        zip="qc/fastqc/{sample}.{read}_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: ""
    log:
        "logs/fastqc/{sample}.{read}.log"
    threads: 1
    resources:
        mem_mb="10G",
        time="03:00:00"
    wrapper:
        "v1.0.0/bio/fastqc"


rule samtools_stats:
    input:
        "mapped/{sample}.{type}.bam"
    params:
        extra=" ".join(["-t",config["reference"]["region_file"]]),
        region=""
    output:
        "qc/samtools-stats/{sample}.{type}.txt"
    resources:
        mem_mb="10G",
        time="01:00:00"
    log:
        "logs/samtools-stats/{sample}.{type}.log"
    wrapper:
        "v1.0.0/bio/samtools/stats"


rule picard_collect_hs_metrics:
    input:
        bam="mapped/{sample}.{type}.bam",
        reference="refs/genome.fasta",
        # Baits and targets should be given as interval lists. These can
        # be generated from bed files using picard BedToIntervalList.
        bait_intervals="refs/region.intervals",
        target_intervals="refs/region.intervals"
    output:
        "qc/hs_metrics/{sample}.{type}.txt"
    params:
        # Optional extra arguments. Here we reduce sample size
        # to reduce the runtime in our unit test.
        extra="--SAMPLE_SIZE 1000"
    log:
        "logs/picard/collect_hs_metrics/{sample}.{type}.log"
    resources:
        time="00:55:00"
    wrapper:
        "v1.0.0/bio/picard/collecthsmetrics"


rule multiqc_alignments:
    input:
        expand("qc/{ctype}/{sample}.{ftype}.txt", sample=SAMPLES, ctype=["samtools-stats","hs_metrics"], ftype=["woconsensus", "realigned"])
    output:
        "qc/multiqc_alignments.html"
    log:
        "logs/multiqc/alignment.log"
    params:
        "--interactive  --cl_config 'max_table_rows: 10000'"
    resources:
        mem_mb=get_mem_20_10,
        time="01:00:00"
    shell:
        """
            multiqc {params} --force -o qc -n multiqc_alignments {input}
        """

rule multiqc_reads:
    input:
        expand("qc/fastqc/{sample}.{reads}_fastqc.zip", sample=SAMPLES, reads=["R1","R2"])
    output:
        "qc/multiqc_reads.html"
    log:
        "logs/multiqc/reads.log"
    params:
        "--interactive --force --cl_config 'max_table_rows: 10000'"
    resources:
        mem_mb="20G",
        time="01:00:00"
    shell:
        """
           multiqc {params} -o qc -n multiqc_reads qc/fastqc/ >> {log} 2>&1
        """
