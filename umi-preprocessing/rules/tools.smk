rule get_refs:
    input:
        genome=config["reference"]["genome"],
        known_indels=config["reference"]["known_indels"]
    output:
        genome="refs/genome.fasta",
        known_indels="refs/known_indels.vcf.gz",
        index="refs/known_indels.vcf.gz.tbi"
    resources:
        mem_mb="2G",
        time="01:00:00"
    shell:
        r"""
        mkdir -p refs
        cp {input.genome} {output.genome}
        cp {input.known_indels} {output.known_indels}
        tabix -p vcf {output.known_indels}
        """

rule samtools_faidx:
    input:
        "refs/genome.fasta"
    output:
        "refs/genome.fasta.fai"
    params:
        "" # optional params string
    resources:
        mem_mb="2G",
        time="01:00:00"
    wrapper:
        "v1.26.0/bio/samtools/faidx"

rule query_bam_sort:
    input:
        "{file}.bam"
    output:
        "{file}_qsorted.bam"
    resources:
        mem_mb="20G",
        time="00:30:00"
    log:
        "logs/picard/query_bam_sort/{file}.log"
    shell:
        r"""
        picard SortSam I={input} \
        SORT_ORDER=queryname \
        o={output} &> {log}
        """

rule coordinate_bam_sort:
    input:
        "{file}.bam"
    output:
        "{file}_csorted.bam"
    resources:
        mem_mb="20G",
        time="00:30:00"
    log:
        "logs/picard/coordinate_bam_sort/{file}.log"
    shell:
        """
        picard SortSam -I {input} --SORT_ORDER coordinate -O {output} &> {log}
        """

rule bwa_index:
    input:
        "refs/genome.fasta"
    output:
        idx=multiext("refs/genome.fasta", ".amb", ".ann", ".bwt", ".pac", ".sa")
    log:
        "logs/bwa_index/genome.log"
    params:
        prefix="refs/genome.fasta",
        algorithm="bwtsw"
    resources:
        mem_mb="10G",
        time="02:00:00"
    wrapper:
        "v1.25.0/bio/bwa/index"

rule create_dict:
    input:
        "refs/genome.fasta"
    output:
        "refs/genome.dict"
    log:
        "logs/picard/create_dict.log"
    params:
        extra=""  # optional: extra arguments for picard.
    wrapper:
        "v3.0.2/bio/picard/createsequencedictionary"

rule samtools_index:
    input:
        bam="mapped/{file}.bam"
    output:
        bai="mapped/{file}.bam.bai"
    log:
        err="logs/samtools/{file}.index.log"
    resources:
        mem_mb="10G",
        time="01:00:00"
    shell:
        """
        samtools index {input.bam} {output.bai} &> {log.err}
        """

rule bed_to_interval_list:
    input:
        bed=config["reference"]["region_file"],
        dict="refs/genome.dict"
    output:
        intervals="refs/region.intervals"
    log:
        err="logs/picard/bedtointervallist.log"
    params:
        # optional parameters
        extra="--SORT true", # sort output interval list before writing
    resources:
        mem_mb="10G",
        time="01:00:00"
    shell:
        """
        picard BedToIntervalList {params.extra} --INPUT {input.bed} --SEQUENCE_DICTIONARY {input.dict} --OUTPUT {output.intervals} &> {log.err}
        """
