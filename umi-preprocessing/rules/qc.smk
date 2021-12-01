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
    wrapper:
        "0.80.2/bio/fastqc"


rule samtools_stats:
    input:
        "mapped/{sample}.{type}.bam"
    params:
        extra=" ".join(["-t",config["general"]["region_file"]]),
        region=""
    output:
        "qc/samtools-stats/{sample}.{type}.txt"
    log:
        "logs/samtools-stats/{sample}.{type}.log"
    wrapper:
        "0.80.2/bio/samtools/stats"


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
        "SAMPLE_SIZE=1000"
    log:
        "logs/picard_collect_hs_metrics/{sample}.{type}.log"
    wrapper:
        "0.80.2/bio/picard/collecthsmetrics"


rule multiqc_alignments:
    input:
        expand("qc/{ctype}/{sample}.{ftype}.txt", sample=SAMPLES, ctype=["samtools-stats","hs_metrics"], ftype=["consensusreads","woconsensus","filtered","realigned"])
    output:
        report("qc/multiqc_alignments.html", caption="../report/multiqc_alignments.rst", category="Quality control")
    log:
        "logs/multiqc.log"
    wrapper:
         "0.80.2/bio/multiqc"


rule multiqc_reads:
    input:
        expand("qc/fastqc/{sample}.{ftype}_fastqc.zip", sample=SAMPLES, ftype=["R1","R2"])
    output:
        report("qc/multiqc_reads.html", caption="../report/multiqc_reads.rst", category="Quality control")
    log:
        "logs/multiqc.log"
    wrapper:
         "0.80.2/bio/multiqc"
