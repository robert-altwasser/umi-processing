rule get_refs:
    input:
        genome=config["reference"]["genome"],
        known_indels=config["reference"]["known_indels"]
    output:
        genome="refs/genome.fasta",
        known_indels="refs/known_indels.vcf.gz",
        index="refs/known_indels.vcf.gz.tbi"
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
    wrapper:
        "0.64.0/bio/samtools/faidx"


rule bwa_index:
    input:
        "refs/genome.fasta"
    output:
        multiext("refs/genome.fasta", ".amb", ".ann", ".bwt", ".pac", ".sa")
    log:
        "logs/bwa_index/genome.log"
    params:
        prefix="refs/genome.fasta",
        algorithm="bwtsw"
    wrapper:
        "0.64.0/bio/bwa/index"


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
        "0.64.0/bio/picard/createsequencedictionary"


rule samtools_index:
    input:
        "mapped/{prefix}.bam"
    output:
        "mapped/{prefix}.bam.bai"
    wrapper:
        "0.78.0/bio/samtools/index"


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
        "SORT=true" # sort output interval list before writing
    wrapper:
        "0.64.0/bio/picard/bedtointervallist"
