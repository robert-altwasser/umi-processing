##########################################
### tumor purity with PureCN
##########################################

rule cnvkit:
    input:
        samples = expand(path_to_mapped + "{sample}.realigned.bam", sample = SAMPLES),
        control = expand(path_to_mapped + "{control}.realigned.bam", control = CONTROL)
    params:
        targets = config["reference"]["region_file"],
        fasta = config["reference"]["genome"],
        anno = config["reference"]["anno_file"],
        dir = "cnvKIT",
    resources:
        threads = 128,
        time = "24:00:00",
        mem_mb = "160G"
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
    resources:
        threads = 1,
        time = "01:00:00"
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
    resources:
        threads = 1,
        time = "24:00:00"
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
    resources:
        threads = 1,
        time = "1:00:00"
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
        expand("cnvKIT/{control}.vcf.gz", control = CONTROL)
    params:
        vcf = "pureCN/results/merged.vcf",
    output:
        vcf_gz = "pureCN/results/merged.vcf.gz",
        vcf_tb = "pureCN/results/merged.vcf.gz.tbi"
    resources:
        threads = 1,
        time = "01:00:00"
    run:
        shell("bcftools merge \
                --merge all \
                {input} \
                -O v \
                -o {params.vcf}")
        shell("bgzip {params.vcf}")
        shell("tabix {output.vcf_gz}")

# Recommended: Provide a normal panel VCF to remove mapping biases, pre-compute
# position-specific bias for much faster runtimes with "large panels"
# This needs to be done only once for each assay

### The program exits on "1". I therefore catch it and send exitcode 0
rule create_pon:
    input:
       "pureCN/results/merged.vcf.gz"
    output:
        "pureCN/pon/mapping_bias_assay_hg38.rds",
        "pureCN/pon/mapping_bias_hq_sites_assay_hg38.bed"
    params:
        purecn_path = "PURECN=" + config["pureCN"]["path"]
    log:
        "logs/create_pon.log"
    resources:
        threads = 1,
        mem_mb = "20G",
        time = "04:00:00"
    shell:
         """
export {params.purecn_path}
set +e
exitcode=1

Rscript $PURECN/NormalDB.R \
   --out-dir 'pureCN/pon/' \
   --normal-panel {input} \
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
        vcf = "cnvKIT/{sample}_dbsnp.vcf.gz",
        tumor ="cnvKIT/{sample}.realigned.cnr",
        segfile = "cnvKIT/{sample}.seg",
        pon = "pureCN/pon/mapping_bias_assay_hg38.rds"
    output:
        "pureCN/results/{sample}_pureCN.csv"
    params:
        sample = "{sample}",
        prefix = "pureCN/results/{sample}_pureCN",
        PURECN = config["pureCN"]["path"]
    log:
         "logs/pureCN/{sample}_pureCN.log"
    resources:
        threads = 1,
        time = "04:00:00",
        mem_mb = "20G"
    shell:
        "Rscript {params.PURECN}/PureCN.R \
            --out {params.prefix}  \
            --sampleid {params.sample} \
            --tumor {input.tumor} \
            --seg-file {input.segfile} \
            --mapping-bias-file {input.pon} \
            --vcf {input.vcf} \
            --genome hg38 \
            --fun-segmentation Hclust \
            --force --post-optimize --seed 123 &> {log}"

def get_purity(wildcards):
    pureCN_file = "pureCN/results/" + wildcards.sample +"_pureCN.csv"
    purity = linecache.getline(pureCN_file, 2)
    return purity.split(",")[1]

def get_ploidy(wildcards):
    pureCN_file = "pureCN/results/" + wildcards.sample +"_pureCN.csv"
    ploidy = linecache.getline(pureCN_file, 2)
    return round(float(ploidy.split(",")[2]))

### normalise 
rule cnvKIT_normalize:
    input:
        vcf_file =  path_to_snp + "{sample}.vcf",
        cnvKIT_result = "cnvKIT/{sample}.realigned.cns"
    output:
        "normalized/{sample}.call.cns"
    log:
        "logs/{sample}_cnvKIT_purity.log"
    resources:
        threads = 1,
        time = "04:00:00"
    shell:
         "cnvkit.py call \
             {input.cnvKIT_result} \
             --drop-low-coverage \
             -y  \
             --vcf {input.vcf_file} \
             -m none \
             -o {output} &> {log}"

### normalise for purity & ploidy
rule cnvKIT_purity:
    input:
        vcf_file =  path_to_snp + "{sample}.vcf",
        cnvKIT_result = "cnvKIT/{sample}.realigned.cns",
        pureCN_result = "pureCN/results/{sample}_pureCN.csv"
    params:
        purity = get_purity,
        ploidy = get_ploidy
    output:
        "normalized/{sample}.call_purity.cns"
    log:
        "logs/{sample}_cnvKIT_purity.log"
    resources:
        threads = 1,
        time = "04:00:00"
    shell:
         "cnvkit.py call \
             {input.cnvKIT_result} \
             --ploidy {params.ploidy} \
             --purity {params.purity} \
             --drop-low-coverage \
             -y  \
             --vcf {input.vcf_file} \
             -m none \
             -o {output} &> {log}"


rule cnvKIt_vcf:
    input:
        "normalized/{sample}.call.cns"
    output:
        "vcf/{sample}.call.vcf"
    log:
         "logs/{sample}_cnvKIT_vcf.log"
    resources:
        threads = 1,
        time = "04:00:00"
    shell:
         "cnvkit.py export vcf \
             {input} \
             -y  \
             -o {output} &> {log}"

rule cnvKIT_plot:
    input:
        cnvKIT_call = "normalized/{sample}.call.cns",
        vcf_file =  path_to_snp + "{sample}.vcf",
        tumor = "cnvKIT/{sample}.realigned.cnr"
    log:
         "logs/{sample}_cnvKIT_plot.log"
    output:
        "plots/{sample}_scatter.pdf"
    resources:
        threads = 1,
        time = "04:00:00"
    shell:
        "cnvkit.py scatter \
            {input.tumor} \
            -s {input.cnvKIT_call} \
            -v {input.vcf_file} \
            --trend \
            --output {output} &> {log}"

