rule map_reads1:
    input:
        unmapped="unmapped/{sample}.unmapped.bam",
        genome="refs/genome.fasta",
        genomeindex="refs/genome.fasta.fai",
        genomedict="refs/genome.dict",
        bwaindex=multiext("refs/genome.fasta", ".amb", ".ann", ".bwt", ".pac", ".sa")
    output:
        temp("mapped/{sample}.woconsensus.bam")
    params:
        musage=config["picard"]["memoryusage"],
        temp_file = temp("mapped/{sample}.temp.bam")
    log:
        "logs/mapping/{sample}.woconsensus.log"
    threads:
        8
    resources:
        mem_mb="70G",
        time="20:00:00"
    shell:
        """
        picard {params.musage} SamToFastq I={input.unmapped} F=/dev/stdout INTERLEAVE=true \
        | bwa mem -p -t 8 {input.genome} /dev/stdin \
        | picard {params.musage} MergeBamAlignment \
        UNMAPPED={input.unmapped} ALIGNED=/dev/stdin O={output} R={input.genome} \
        SO=coordinate ALIGNER_PROPER_PAIR_FLAGS=true MAX_GAPS=-1 ORIENTATIONS=FR VALIDATION_STRINGENCY=SILENT &> {log}
        """

rule GroupReads:
    input:
        "mapped/{sample}.woconsensus.bam"
    output:
        bam="unmapped/{sample}.groupedumi.bam",
        hist="metrices/fgbio/{sample}.groupedumi.histo.tsv",
    params:
        extra=config["fgbio"]["groupreads"]
    resources:
        mem_mb="30G",
        time="02:00:00"
    log:
        "logs/fgbio/group_reads/{sample}.log"
    wrapper:
        "v1.0.0/bio/fgbio/groupreadsbyumi"

rule ConsensusReads:
    input:
        "unmapped/{sample}.groupedumi.bam"
    output:
        temporary("unmapped/{sample}.consensusreads.bam")
    params:
        extra=config["fgbio"]["callconsensus"]
    resources:
        mem="10G",
        mem_mb="10G",
        time="02:00:00"
    log:
        "logs/fgbio/consensus_reads/{sample}.log"
    wrapper:
        "v1.0.0/bio/fgbio/callmolecularconsensusreads"
####
### Common errors:
# "Error in writing fastq file /dev/stdout"
# means the pipeline collapsed. Probably an error in MergeBamAlignment

rule map_reads2:
    input:
        unmapped="unmapped/{sample}.consensusreads_qsorted.bam",
        genome="refs/genome.fasta",
        genomeindex="refs/genome.fasta.fai",
        genomedict="refs/genome.dict",
        bwaindex=multiext("refs/genome.fasta", ".amb", ".ann", ".bwt", ".pac", ".sa")
    output:
        "mapped/{sample}.consensusreads.bam"
    params:
        musage=config["picard"]["memoryusage"],
    log:
        "logs/mapping/{sample}.consensusreads.log"
    threads:
        8
    resources:
        mem="50G",
        mem_mb="50G",
        time="02:00:00"
    shell:
        r"""
        picard {params.musage} SamToFastq I={input.unmapped} F=/dev/stdout INTERLEAVE=true \
        | bwa mem -p -t 8 {input.genome} /dev/stdin \
        | picard {params.musage} MergeBamAlignment \
        UNMAPPED={input.unmapped} ALIGNED=/dev/stdin O={output} R={input.genome} \
        SO=queryname CREATE_INDEX=true ALIGNER_PROPER_PAIR_FLAGS=true MAX_GAPS=-1 ORIENTATIONS=FR VALIDATION_STRINGENCY=SILENT &> {log}
        """

rule FilterConsensusReads:
    input:
        "mapped/{sample}.consensusreads.bam"
    output:
        "mapped/{sample}.filtered.bam"
    params:
        extra=config["fgbio"]["fextra"],
        min_base_quality=config["fgbio"]["fminq"],
        min_reads=[3],
        ref="refs/genome.fasta",
        musage=config["picard"]["memoryusage"],
    log:
        "logs/fgbio/filterconsensusreads/{sample}.log"
    threads: 1
    resources:
        mem_mb="50G",
        time="01:00:00"
    shell:
        r"""
        fgbio {params.musage} FilterConsensusReads \
         -i {input} \
         -o {output} \
         -r {params.ref} \
         --min-reads {params.min_reads} \
         --min-base-quality {params.min_base_quality} \
         &> {log}
         """

rule realignertargetcreator:
    input:
        bam="mapped/{sample}.filtered_csorted.bam",
        bam_index="mapped/{sample}.filtered_csorted.bam.bai",
        bed=config["reference"]["region_file"],
        ref="refs/genome.fasta",
        known="refs/known_indels.vcf.gz"
    output:
        "realigned/{sample}.intervals"
    log:
        "logs/gatk/realignertargetcreator/{sample}.log"
    params:
        extra="",  # optional
        java_opts=config["picard"]["memoryusage"],
    threads: 10
    resources:
        mem="70G",
        mem_mb="70G",
        time="02:00:00"
    shell:
        r"""
        gatk3 {params.java_opts} -T RealignerTargetCreator {params.extra} -nt {threads} -I {input.bam} -R {input.ref} -known {input.known} -L {input.bed} -o {output} &> {log}
        """


rule indelrealigner:
    input:
        bam="mapped/{sample}.filtered_csorted.bam",
        bam_index="mapped/{sample}.filtered_csorted.bam.bai",
        bed=config["reference"]["region_file"],
        ref="refs/genome.fasta",
        known="refs/known_indels.vcf.gz",
        target_intervals="realigned/{sample}.intervals"
    output:
        bam="mapped/{sample}.realigned.bam"
    log:
        "logs/gatk3/indelrealigner/{sample}.log"
    params:
        extra="",  # optional
        java_opts=config["picard"]["memoryusage"], # optional
    threads: 5
    resources:
        mem="70G",
        mem_mb="70G",
        time="05:00:00"
    shell:
        r"""
        gatk3 {params.java_opts} -T IndelRealigner {params.extra} -I {input.bam} -R {input.ref} -known {input.known} -L {input.bed} --targetIntervals {input.target_intervals} -o {output} &> {log}
        """
