# umi-processing

- build by Raphael Hablesreiter
- Similar pipeline, according to Raphael:

> Die Pipeline von Martin beruht auf einer Pipeline einer Kollegin. Und die von mir ist eine abgespeckte und vereinfachte Version. Und die von mir ist eine abgespeckte und vereinfachte Version. somVarWes benutzt varscan für variantcalling und meine vardict.

- demultiplexing of UMI explained [here](./../docs/raphael/demultiplexing-data-containing-unique-molecular-indexes-(umis).pdf)

### 1. Preprocessing

![Snakemake workflow of the Preprocessing. (Sorry for messed up PDF.)](./images/umi_preprocessing.pdf){width=100% height=400}

3. **References and Indexing**: Getting reference sequences, annotation and make indexes. 

1. **Barcode extraction**: Determines the barcode for each read in a Illumina sequencing lane. This way, it is clear, which read belongs to which sample. 

2. **Basecalls to sam**: *Demultiplexing*; The raw sequencing data is put into (yet) unmapped SAM/BAM files per sample according to the barcodes. SAM/BAM files are the only ones that an store the sequence and the UMI information.

4. **first mapping**: The BAM files are converted to FASTQ, and then the FASTQ files are mapped to the genome.

5. **Group reads**: Sequences are grouped accoring to their UMI sequence.

6. **Consensus reads**: PCR can introduce errors, which can be indistinguishable from *real* mutations. Therefor, the reads are grouped by their UMIs, and only the consensus sequences are kept. Here, Consensus reads filters all reads that don't appear *at least three times per UMI*.

7. **second mapping**: Consensus sequences mapped to the genome again.

8. **Filter Consensus Reads**: Reads can be filtered here again. Currently, this isn't really used much (@TODO).

9. **local realignment**: Around known indels, local realignments are performend. Especially towards the end of reads, "mismatch" is cheaper than gap opening, leading to false positives.

### 2. Variant calling

![Snakemake workflow of the Variant calling. (Sorry for messed up PDF.)](./images/umi_variantcalling.pdf){width=100% height=400}

1. **vardict**: single (end) mode. *Vardict* has the following features:
   - amplicon bias from targeted sequencing experiment awareness
   - rescue of long indels by realigning *bwa* soft clipped reads
   - Philosophy of calling "everthing" and filtering afterwards

2. **ebfilter**: Empirical Bayesian false positive filtering of somatic mutations in cancer genome sequencing. This is done via:
   - estimating sequencing error model using *control* sequencing data (@TODO: we don't have those)
   - compare mismatch ratio with observed mismatch ratio of tumor samples
   - if the mismatch ratio of the tumor sample significantly deviates from the predicted mismatch ratio, it is probably a highly likely somatic mutation

3. **annovar**:
