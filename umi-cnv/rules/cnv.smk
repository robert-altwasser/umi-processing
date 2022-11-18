##########################################
### tumor purity with PureCN
##########################################

rule cnvkit:
    input:
        samples = expand(path_to_mapped + "{sample}.realigned.bam", sample = SAMPLES),
        control = expand(path_to_mapped + "{contol}.realigned.bam", contol = CONTROL)
    params:
        targets = config["reference"]["region_file"],
        fasta = config["reference"]["genome"],
        anno = config["reference"]["annot_file"],
        dir = "cnvKIT",
    resources:
        threads = 10
    log:
         "logs/cnvkit.log"
    output:
        cnr = expand("cnvKIT/{sample}.realigned.cnr", sample = SAMPLES),
        cns = expand("cnvKIT/{sample}.realigned.cns", sample = SAMPLES)
    shell:
        """
           cnvkit.py batch \
               {input.samples} \
               -p {resources.threads} \
               --normal {input.control} \
               --seq-method amplicon \
               --processes {resources.threads} \
               --drop-low-coverage \
               --scatter --diagram \
               --targets {params.targets} \
               --fasta {params.fasta} \
               --annotate {params.anno} \
               --output-dir {params.dir} &> {log}
        """

rule bgzip:
    input:
        path_to_snp + "{sample}.vcf"
    output:
        files = "cnvKIT/{sample}.vcf.gz",
        index = "cnvKIT/{sample}.vcf.gz.csi"
    run:
       shell("bgzip \
                 --stdout --index \
                 {input} > {output.files}")
       shell("bcftools index {output.files}")

rule bcftools_annotate:
    input:
        annot_file = config["reference"]["known_indels"],
        files = "cnvKIT/{sample}.vcf.gz"
    output:
        "cnvKIT/{sample}_dbsnp.vcf.gz"
    shell:
        "bcftools annotate \
             --annotation {input.annot_file} \
             --columns ID \
             --output {output} \
             --output-type z \
             {input.files}"

rule export_seg:
    input:
        "cnvKIT/{sample}.realigned.cns"
    output:
       "cnvKIT/{sample}.seg"
    shell:
        "cnvkit.py export seg \
            {input} \
            --enumerate-chroms \
            -o {output}"

##########################################
### tumor purity with PureCN
##########################################
rule merge_control:
    input:
        expand("cnvKIT/{sample}.vcf.gz", sample = CONTROL)
    params:
        vcf = "pureCN/merged.vcf",
    output:
        vcf_gz = "pureCN/merged.vcf.gz",
        vcf_tb = "pureCN/merged.vcf.gz.tbi"
    run:
        shell("bcftools merge \
                --merge all \
                {input} \
                -O v \
                -o {params.vcf}")
        shell("bgzip {params.vcf}")
        shell("tabix {output.vcf_gz}")

# Recommended: Provide a normal panel VCF to remove mapping biases, pre-compute
# position-specific bias for much faster runtimes with large panels
# This needs to be done only once for each assay

### The program exits on "1". I therefore catch it and send exitcode 0
rule create_pon:
    input:
       "pureCN/merged.vcf.gz"
    output:
        "pon/mapping_bias_assay_hg38.rds",
        "pon/mapping_bias_hq_sites_assay_hg38.bed"
    log:
        "logs/create_pon.log"
    shell:
         """
         set +e
         Rscript $PURECN/NormalDB.R \
            --outdir 'pureCN' \
            --normal_panel {input} \
            --assay assay \
            --genome hg38 \
            --force
         if [ $exitcode -eq 1 ]
         then
             exit 0
         else
             exit 1
         fi
            """

rule pureCN:
    input:
        vcf = "pureCN/{sample}_dbsnp.vcf.gz",
        tumor ="CNVKit/{sample}.realigned.cnr",
        segfile = "CNVKit/{sample}.seg",
        pon = "pon/mapping_bias_assay_hg38.rds"
    output:
        "pureCN/{sample}_pureCN.csv"
    params:
        sample = "{sample}",
        prefix = "pureCN/{sample}_pureCN",
    log:
         "logs/{sample}_pureCN.log"
    shell:
        "Rscript " + PURECN + "/PureCN.R \
            --out {params.prefix}  \
            --sampleid {params.sample} \
            --tumor {input.tumor} \
            --segfile {input.segfile} \
            --mappingbiasfile {input.pon} \
            --vcf {input.vcf} \
            --genome hg38 \
            --funsegmentation Hclust \
            --force --postoptimize --seed 123 &> {log}"

def get_purity(wildcards):
    pureCN_file = "pureCN/" + wildcards.sample +"_pureCN.csv"
    purity = linecache.getline(pureCN_file, 2)
    return purity.split(",")[1]

def get_ploidy(wildcards):
    pureCN_file = "pureCN/" + wildcards.sample +"_pureCN.csv"
    ploidy = linecache.getline(pureCN_file, 2)
    return round(float(ploidy.split(",")[2]))

### normalise for purity & ploidy
### with purity 
# rule cnvKIt_purity:
#     input:
#         pureCN_result = "pureCN/{sample}_pureCN.csv",
#         vcf_file =  path_to_snp + "{sample}.vcf",
#         cnvKIT_result = "cnvKIT/{sample}.realigned.cns"
#     params:
#         purity = get_purity,
#         ploidy = get_ploidy
#     output:
#         "cnvKIT/{sample}.call.cns"
#     log:
#         "logs/{sample}_cnvKIT_purity.log"
#     shell:
#          "cnvkit.py call \
#              {input.cnvKIT_result} \
#              --purity {params.purity} \
#              --ploidy {params.ploidy} \
#              --drop-low-coverage \
#              -y  \
#              --vcf {input.vcf_file} \
#              -m none \
#              -o {output} &> {log}"
### normalise for purity & ploidy
rule cnvKIt_purity:
    input:
        pureCN_result = "pureCN/{sample}_pureCN.csv",
        vcf_file =  path_to_snp + "{sample}.vcf",
        cnvKIT_result = "cnvKIT/{sample}.realigned.cns"
    params:
        ploidy = get_ploidy
    output:
        "cnvKIT/{sample}.call.cns"
    log:
        "logs/{sample}_cnvKIT_purity.log"
    shell:
         "cnvkit.py call \
             {input.cnvKIT_result} \
             --ploidy {params.ploidy} \
             --drop-low-coverage \
             -y  \
             --vcf {input.vcf_file} \
             -m none \
             -o {output} &> {log}"

rule cnvKIt_vcf:
    input:
        "cnvKIT/{sample}.call.cns"
    output:
        "vcf/{sample}.call.vcf"
    log:
         "logs/{sample}_cnvKIT_vcf.log"
    shell:
         "cnvkit.py export vcf \
             {input} \
             -y  \
             -o {output} &> {log}"

rule cnvKIT_plot:
    input:
        cnvKIT_call = "cnvKIT/{sample}.call.cns",
        vcf_file =  path_to_snp + "{sample}.vcf",
        tumor = "cnvKIT/{sample}.realigned.cnr"
    log:
         "logs/{sample}_cnvKIT_plot.log"
    output:
        "plots/{sample}_scatter.pdf"
    shell:
        "cnvkit.py scatter \
            {input.tumor} \
            -s {input.cnvKIT_call} \
            -v {input.vcf_file} \
            --trend \
            --output {output} &> {log}"

