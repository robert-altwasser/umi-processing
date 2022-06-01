rule get_refs:
    input:
        genome=config["reference"]["genome"],
        known_indels=config["reference"]["known_indels"]
    output:
        genome="refs/genome.fasta",
        known_indels="refs/known_indels.vcf.gz",
        index="refs/known_indels.vcf.gz.tbi"
    resources:
        mem_mb="02G",
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
        "v1.0.0/bio/samtools/faidx"

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
        "v1.0.0/bio/bwa/index"

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
        "v1.0.0/bio/picard/createsequencedictionary"

rule samtools_index:
    input:
        "mapped/{sample}.bam"
    output:
        "mapped/{sample}.bam.bai"
    resources:
        mem_mb="2G",
        time="01:00:00"
    wrapper:
        "v1.0.0/bio/samtools/index"

rule bed_to_interval_list:
    input:
        bed=config["general"]["region_file"],
        dict="refs/genome.dict"
    output:
        "refs/region.intervals"
    log:
        "logs/picard/bedtointervallist/a.log"
    params:
        # optional parameters
        extra="--SORT true", # sort output interval list before writing
    resources:
        mem_mb=1024,
        time="01:00:00"
    wrapper:
        "v1.0.0/bio/picard/bedtointervallist"
