- build by Raphael Hablesreiter & Robert Altwasser

# Demultiplexing

## Sample sheet

To demultiplex Illumina basecalls into different samples, `bcl2fastq` can be used ([>LINK<](https://emea.support.illumina.com/sequencing/sequencing_software/bcl2fastq-conversion-software.html)). It has to be executed in the base directory of the sequencing run (the one with the `RunInfo.xml` in it). A `SampleSheet.csv` has to be created containing the (7') barcode indexes for each sample. If UMIs are present, their length can be given in sample sheet.
For the demultiplexing to run, we need a sample sheet. A template can be downloaded here [>LINK<](https://sapac.support.illumina.com/downloads/sample-sheet-v2-template.html)

Let's say the *Project Registration* form has the following format:

| Library order number | pool name   | Library  Code/Name | I7_Index_ID | I7_Index          | I5_Index_ID | I5_Index | …   | Remarks |
| -------------------- | ----------- | ------------------ | ----------- | ----------------- | ----------- | -------- | --- | ------- |
| 1                    | P1557_BL_01 | S-BeLOV-248164     | IDT8_i7_1   | CTGATCGTNNNNNNNNN | IDT8_i5_1   | ATATGCGC | …   | Lane 1  |
| 2                    | P1557_BL_01 | S-BeLOV-248536     | IDT8_i7_2   | ACTCTCGANNNNNNNNN | IDT8_i5_2   | TGGTACAG | …   | Lane 2  |

the corresponding sample sheet would look like this:

```
[Header],,,
FileFormatVersion,2,,
MyRunName,P1557,,
InstrumentPlatform,NextSeq6000,,
InstrumentType,NextSeq6000,,
,,,
[Reads],,,
Read1Cycles,148,,
Index1Cycles,17,,
Index2Cycles,8,,
Read2Cycles,148,,
,,,
[Data],,,
Lane,Sample_ID,Sample_Name,index,index2
1,S-BeLOV-248164,S-BeLOV-248164,CTGATCGT,GCGCATAT
2,S-BeLOV-248536,S-BeLOV-248536,ACTCTCGA,CTGTACCA
```
- The information for the [Reads] section can be found in the *project_registration_form* or *RunInfo.xml*
- Please note the *NNNNNNNNN* in the I7_Index are removed
- the *index2*, which holds the I5_Index is ***reverse complement!***. This can be done using this link [>LINK<](https://arep.med.harvard.edu/labgc/adnan/projects/Utilities/revcomp.html)

## config file

This file has to give the paths to different annotation files. Especially important are

- general:
    - defines key paths to run the pipeline
    - `control`: Are control samples present? If `True`, `EBFilter` will be performed. (See section [EB filter](#EB filter)). The names of the control samples should be stored in a plain text file. The location of the plain text file should be given as `edit: normals: /Path`.

- reference:
    - paths to the reference genome and annotation files
- readstructure: This has to be adjusted to the run. See below
- region_file: make sure you have the correct target file
- picard-> memoryusage: Adjust for bigger datasets

### Readstructure

The *readstructure* tells the demultiplexer which part of the reads is an adapter, and what is the sequence. Information about this can be found in `RunInfo.txt` and the meta data file with the barcodes. Please note that the first index also contain the UMIs

```
<Read Number="1" NumCycles="148" IsIndexedRead="N"/>
<Read Number="2" NumCycles="17" IsIndexedRead="Y"/>
<Read Number="3" NumCycles="8" IsIndexedRead="Y"/>
<Read Number="4" NumCycles="148" IsIndexedRead="N"/>
```

Means (in `bcl2fastq` syntax):

```
readstructure: "y148,i8y9,i8,y148"
```

- `y148`: 184bp transcript
- `i8`: 8bp barcode sample
- `y9`: 9bp index molecular (UMI)
- also `S`: skip

If you have no information, one can also just convert the entire sequences to fastq without de-multiplexing and without trimming. Note that you need to set the entire read length to template. **148T** in this example. Then you can `grep` the barcodes and stuff.

```
picard  IlluminaBasecallsToFastq B=./{MY_RUN}/Data/Intensities/BaseCalls/ L=1 RS=148T INCLUDE_NON_PF_READS=false COMPRESS_OUTPUTS=false RUN_BARCODE=MY_RUN OUTPUT_PREFIX=MY_RUN READ_NAME_FORMAT=ILLUMINA  NUM_PROCESSORS=1 IGNORE_UNEXPECTED_BARCODES=false FORCE_GC=false
```

# Preprocessing

![rule_prep_filtered.svg](images/umi_prep.svg)

1.  **map_reads1**: The BAM files are converted to FASTQ, and then the FASTQ files are mapped to the genome.
    
2.  **Group reads**: Sequences are grouped according to their UMI sequence.
    
3.  **Consensus reads**: PCR can introduce errors, which can be indistinguishable from *real* mutations. Therefor, the reads are grouped by their UMIs, and only the consensus sequences are kept. Here, Consensus reads filters all reads that don't appear *at least three times per UMI*.
    
4.  **map_reads2**: Consensus sequences mapped to the genome again.
    
5.  **FilterConsensusReads**: Reads can be filtered here according to base quality or consensus error rate.
    
6.  **local realignment**:
    
    - Around known indels, local realignments are performed. Especially towards the end of reads, "mismatch" is cheaper than gap opening, leading to false positives.
    - genome aligners can only consider each read independently
    - local realignment considers all reads spanning a given position
        - parsimonious alignment of reads
            ![indels_realign.png](images/realign.png)
            ![indels_realign_2.png](images/realign_2.png)

# Variant calling

## vardict:
    - single (end) mode
    - “ultra sensitive variant caller for [..] variant calling from BAM files”
    - philosophy is to “call everything”, and filter later
    - calls SNV, MNV, InDels, complex and structural variants
    - insertions and deletions often work as tandem
    - if InDel is detected, surrounding area is scanned for more InDels or mismatches
        - combination to one complex variant
    - calling of structural variants with paired end data
    - works with amplicons/targeted sequencing; single end only

## EB filter
    - Empirical Bayesian false positive filtering of somatic mutations in cancer genome sequencing. This is done via:
    - **if you do not have a healthy control, set the value to "False" in the config file**
    - estimating sequencing error model using *control* sequencing data
    - compare mismatch ratio with observed mismatch ratio of tumor samples
    - if the mismatch ratio of the tumor sample significantly deviates from the predicted mismatch ratio, it is probably a highly likely somatic mutation
    - Since we usually don't have healthy control, this should not be done.
    - An alternative is using random tumor samples as background.

## anntoation:
    - ANNOVAR: adds gene/region/variant based annotation [>LINK<](https://annovar.openbioinformatics.org/en/latest/)
        - COSMIC: *Catalogue Of Somatic Mutations In Cancer*
        - dbSNP: known human SNP data base by *NCBI*
        - clinVAR: known mutations in a clinical context
    - HDR: *High Discrepancy Region*; regions with many localized differences

## Filtering of results
    - *TVAF*: portion of reads with variation
        - should have high difference between control and tumor (impurities)
        - VAF == 1: SNP in all cells, almost always germline 
        - VAF == 0.5: SNP on one chromosome; from one parent
        - else: tumor impurities
    - *clinical*: Is the gene of clinical interest?
    - *dbSNP*: Is the variance known?
    - *coverage*: coverage of mutation and normal
    - *EBFilter*: Is the mutation somatic or germline?
    - ...
    - **still a lot of visual verification necessary (IGV)**

# Glossary

AML
: Acute Myeloische Leukemia

HSC
: hematopoietic stem cell

HSCT
: hematopoietic stem cell transplantation

CDR
: commonly deleted region

VAF
: variant allele frequency

UMI Adapters
: PCR can introduce errors, which can be indistinguishable from *real* mutations. Therefor, every strand of sequenced DNA is marked with a unique molecular identifier (UMI). After PCR amplification, the reads are grouped by their UMIs, and only the consensus sequences are kept.

![Schematic of UMI adapters. Question: is the "orange" example correct?](images/umis.png)

Clonal hematopoiesis (CH)
: somatic mutation in leukemia-associated genes in the blood of individuals without hematologic disease.

Demultiplexing
: The raw sequencing data is put into (yet) unmapped SAM/BAM files per sample according to the barcodes.

# Troubleshooting

- programs crash without error:
    - usually not enough memory
    - increase `picard` memory in `config.yaml`

- `barcode_metrices.txt` has only "Unmatched" reads
    - indexes in `barcodes_params` wrong

- `barcode_metrices.txt` has **almost** only "unmatched" reads
    - 5' indexes not reverse complement

- `XX.unmapped.bam` files remain empty:
    - indexes in `library_param.csv` and `barcode_params` don't match
    - check `picard` log for `picard.PicardException: Read records with barcode CGCAATCTNNNNNNNNNACAGGCAT, but this barcode was not expected. (Is it referenced in the parameters file?)`
