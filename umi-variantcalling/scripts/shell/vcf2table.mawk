#!/bin/sh

# conversion of freebayes output to table


##commandline="freebayes -f /fast/groups/ag_damm/work/ref/genome/gatk/hg38/hg38.fasta -C 3 -F 0.02 -q 25 -Q 20 recalib/sample1.bam"

#  DP Type=Integer,Description="Total read depth at the locus">
#  DPB Type=Float,Description="Total read depth per bp at the locus; bases in reads overlapping / bases in haplotype">
#  AC Type=Integer,Description="Total number of alternate alleles in called genotypes">
#  AN Type=Integer,Description="Total number of alleles in called genotypes">
#  AF Type=Float,Description="Estimated allele frequency in the range (0,1]">
#  RO Type=Integer,Description="Count of full observations of the reference haplotype.">
#  AO Type=Integer,Description="Count of full observations of this alternate haplotype.">
#  PRO Type=Float,Description="Reference allele observation count, with partial observations recorded fractionally">
#  PAO Type=Float,Description="Alternate allele observations, with partial observations recorded fractionally">
#  QR Type=Integer,Description="Reference allele quality sum in phred">
#  QA Type=Integer,Description="Alternate allele quality sum in phred">
#  PQR Type=Float,Description="Reference allele quality sum in phred for partial observations">
#  PQA Type=Float,Description="Alternate allele quality sum in phred for partial observations">
#  SRF Type=Integer,Description="Number of reference observations on the forward strand">
#  SRR Type=Integer,Description="Number of reference observations on the reverse strand">
#  SAF Type=Integer,Description="Number of alternate observations on the forward strand">
#  SAR Type=Integer,Description="Number of alternate observations on the reverse strand">
#  SRP Type=Float,Description="Strand balance probability for the reference allele: Phred-scaled upper-bounds estimate of the probability of observing the deviation between SRF and SRR given E(SRF/SRR) ~ 0.5, derived using Hoeffding's inequality">
#  SAP Type=Float,Description="Strand balance probability for the alternate allele: Phred-scaled upper-bounds estimate of the probability of observing the deviation between SAF and SAR given E(SAF/SAR) ~ 0.5, derived using Hoeffding's inequality">
#  AB Type=Float,Description="Allele balance at heterozygous sites: a number between 0 and 1 representing the ratio of reads showing the reference allele to all reads, considering only reads from individuals called as heterozygous">
#  ABP Type=Float,Description="Allele balance probability at heterozygous sites: Phred-scaled upper-bounds estimate of the probability of observing the deviation between ABR and ABA given E(ABR/ABA) ~ 0.5, derived using Hoeffding's inequality">
#  RUN Type=Integer,Description="Run length: the number of consecutive repeats of the alternate allele in the reference genome">
#  RPP Type=Float,Description="Read Placement Probability: Phred-scaled upper-bounds estimate of the probability of observing the deviation between RPL and RPR given E(RPL/RPR) ~ 0.5, derived using Hoeffding's inequality">
#  RPPR Type=Float,Description="Read Placement Probability for reference observations: Phred-scaled upper-bounds estimate of the probability of observing the deviation between RPL and RPR given E(RPL/RPR) ~ 0.5, derived using Hoeffding's inequality">
#  RPL Type=Float,Description="Reads Placed Left: number of reads supporting the alternate balanced to the left (5') of the alternate allele">
#  RPR Type=Float,Description="Reads Placed Right: number of reads supporting the alternate balanced to the right (3') of the alternate allele">
#  EPP Type=Float,Description="End Placement Probability: Phred-scaled upper-bounds estimate of the probability of observing the deviation between EL and ER given E(EL/ER) ~ 0.5, derived using Hoeffding's inequality">
#  EPPR Type=Float,Description="End Placement Probability for reference observations: Phred-scaled upper-bounds estimate of the probability of observing the deviation between EL and ER given E(EL/ER) ~ 0.5, derived using Hoeffding's inequality">
#  DPRA Type=Float,Description="Alternate allele depth ratio.  Ratio between depth in samples with each called alternate allele and those without.">
#  ODDS Type=Float,Description="The log odds ratio of the best genotype combination to the second-best.">
#  GTI Type=Integer,Description="Number of genotyping iterations required to reach convergence or bailout.">
#  TYPE Type=String,Description="The type of allele, either snp, mnp, ins, del, or complex.">
#  CIGAR Type=String,Description="The extended CIGAR representation of each alternate allele, with the exception that '=' is replaced by 'M' to ease VCF parsing.  Note that INDEL alleles do not have the first matched base (which is provided by default, per the spec) referred to by the CIGAR.">
#  NUMALT Type=Integer,Description="Number of unique non-reference alleles in called genotypes at this position.">
#  MEANALT Type=Float,Description="Mean number of unique non-reference allele observations per sample with the corresponding alternate alleles.">
#  LEN Type=Integer,Description="allele length">
#  MQM Type=Float,Description="Mean mapping quality of observed alternate alleles">
#  MQMR Type=Float,Description="Mean mapping quality of observed reference alleles">
#  PAIRED Type=Float,Description="Proportion of observed alternate alleles which are supported by properly paired read fragments">
#  PAIREDR Type=Float,Description="Proportion of observed reference alleles which are supported by properly paired read fragments">
#  MIN_DP Type=Integer,Description="Minimum depth in gVCF output block.">
#  END Type=Integer,Description="Last position (inclusive) in gVCF output record.">
#  technology.illumina Type=Float,Description="Fraction of observations supporting the alternate observed in reads from illumina">
# GT Type=String,Description="Genotype">
# GQ Type=Float,Description="Genotype Quality, the Phred-scaled marginal (or unconditional) probability of the called genotype">
# GL Type=Float,Description="Genotype Likelihood, log10-scaled likelihoods of the data given the called genotype for each possible genotype generated from the reference and alternate alleles given the sample ploidy">
# DP Type=Integer,Description="Read Depth">
# AD Type=Integer,Description="Number of observation for each allele">
# RO Type=Integer,Description="Reference allele observation count">
# QR Type=Integer,Description="Sum of quality of the reference observations">
# AO Type=Integer,Description="Alternate allele observation count">
# QA Type=Integer,Description="Sum of quality of the alternate observations">


# ######################## SAMPLE OUTPUT ################################################
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	sample1
# chr1	23295198	.	A	G	5.31588e-14	.	AB=0;ABP=0;AC=0;AF=0;AN=2;AO=3;CIGAR=1X;DP=40;DPB=40;DPRA=0;EPP=3.73412;EPPR=3.06899;GTI=0;LEN=1;MEANALT=1;MQM=60;MQMR=60;NS=1;NUMALT=1;ODDS=32.5582;PAIRED=1;PAIREDR=1;PAO=0;PQA=0;PQR=0;PRO=0;QA=104;QR=1219;RO=37;RPL=0;RPP=9.52472;RPPR=45.7942;RPR=3;RUN=1;SAF=1;SAP=3.73412;SAR=2;SRF=17;SRP=3.5385;SRR=20;TYPE=snp;technology.illumina=1	GT:DP:AD:RO:QR:AO:QA:GL	0/0:40:37,3:37:1219:3:104:0,-2.33839,-100.308
# chr1	23295253	.	T	A	310.627	.	AB=0.5;ABP=3.0103;AC=1;AF=0.5;AN=2;AO=17;CIGAR=1X;DP=34;DPB=34;DPRA=0;EPP=3.13803;EPPR=3.13803;GTI=0;LEN=1;MEANALT=1;MQM=60;MQMR=60;NS=1;NUMALT=1;ODDS=71.5245;PAIRED=1;PAIREDR=1;PAO=0;PQA=0;PQR=0;PRO=0;QA=523;QR=562;RO=17;RPL=13;RPP=13.3567;RPPR=39.9253;RPR=4;RUN=1;SAF=8;SAP=3.13803;SAR=9;SRF=8;SRP=3.13803;SRR=9;TYPE=snp;technology.illumina=1	GT:DP:AD:RO:QR:AO:QA:GL	0/1:34:17,17:17:562:17:523:-37.1341,0,-40.6611
# chr1	23894831	.	T	A	122.938	.	AB=0;ABP=0;AC=2;AF=1;AN=2;AO=5;CIGAR=1X;DP=5;DPB=5;DPRA=0;EPP=3.44459;EPPR=0;GTI=0;LEN=1;MEANALT=1;MQM=62;MQMR=0;NS=1;NUMALT=1;ODDS=11.5366;PAIRED=1;PAIREDR=0;PAO=0;PQA=0;PQR=0;PRO=0;QA=161;QR=0;RO=0;RPL=2;RPP=3.44459;RPPR=0;RPR=3;RUN=1;SAF=5;SAP=13.8677;SAR=0;SRF=0;SRP=0;SRR=0;TYPE=snp;technology.illumina=1	GT:DP:AD:RO:QR:AO:QA:GL	1/1:5:0,5:0:0:5:161:-14.8092,-1.50515,0

mawk '
BEGIN {
    lines = 0;
    # naming for the strandedness info
    # DPF[1]="R1+";
    # DPF[2]="R1-";
    # DPF[3]="R2+";
    # DPF[4]="R2-";

    ################ FREEBAYESVCF2TABLE TRANSLATOR ###################
    # only the mentioned fields are used in the output

    VCF["readDepth"] = "DP";
    VCF["totalAlleles"] = "AN";
    VCF["EstimAlleleFreq"] = "AF";
    VCF["TR1"] = "RO";
    VCF["TR2"] = "AO";
    VCF["Qual1"] = "QR";
    VCF["Qual2"] = "QA";
    VCF["TR1+"] = "SRF";
    VCF["TR1-"] = "SRR";
    VCF["TR2+"] = "SAF";
    VCF["TR2-"] = "SAR";
    VCF["AlleleType"] = "TYPE";
    VCF["MQ2"] = "MQM";
    VCF["MQ1"] = "MQMR";
    VCF["FreqPaired2"] = "PAIRED";
    VCF["FreqPaired1"] = "PAIREDR";
    VCF["FGL"] = "T-GL";
    VCF["StrandBalance1"] = "SRP";
    VCF["StrandBalance2"] = "SAP";
    # VCF["RepeatLength"] = "RUN";

    ####### HEADER 
    # DATA-fields --> HEADERS
    ## 6 basic fields
    HEADER[1] = "Chr";
    HEADER[2] = "Start";
    HEADER[3] = "End";
    HEADER[4] = "Ref";
    HEADER[5] = "Alt";
    HEADER[6] = "Qual";
    # + these fields from the vcf-tags
    HEADER[7] = "readDepth";
    HEADER[8] = "TR1";
    HEADER[9] = "TR1+";
    HEADER[10] = "TR1-";
    HEADER[11] = "TR2";
    HEADER[12] = "TR2+";
    HEADER[13] = "TR2-";
    HEADER[14] = "Qual1";
    HEADER[15] = "Qual2";
    HEADER[16] = "MQ1";
    HEADER[17] = "MQ2";
    HEADER[18] = "StrandBalance1";
    HEADER[19] = "StrandBalance2";
    HEADER[20] = "FreqPaired1";
    HEADER[21] = "FreqPaired2";
    HEADER[22] = "AlleleType";
    HEADER[23] = "FGL";
    # HEADER[22] = "RepeatLength";
    # HEADER[14] = "totalAlleles";
    # HEADER[15] = "EstimAlleleFreq";


    ######## HEADER OUTPUT #############
    printf("Chr");
    # print all the headers
    for (i = 1; i++ < 23;) {
        printf("\t%s",HEADER[i]);
    }
    printf("\n");
}


##### PROCESS LINES #################
/^[^#]/ {
    if (($1 !~ /decoy/) && ($1 !~ /chrUn/) && ($1 !~ /random/) && ($1 !~ /_alt/)) {
        lines++;
        start=$2;
        R=$4;
        A=$5;
        Q=$6;
        RL=length($4);
        AL=length($5);

        ############## INFO FIELD ###################
        # convert VCF tags to array Data
        Info=$8;
        # split Info field by ";" into the IF array (In is the length of IF array)
        In = split(Info,IF,";");
        for (i = 0; ++i <= In;) {
            # split each Info tag by "=" into s
            split(IF[i],s,"=");
            Data[s[1]] = s[2];
        }

        ############## FORMAT ######################
        # sample values
        Format=$9;
        n = split(Format,FFields,":");
        # tumor values
        T=$10;
        split(T,TFields,":");
        # get the data values into an array
        for (i = 0; ++i <= n;) {
            if (FFields[i] == "DP4") {
                split(TFields[i],TDP,",");
                for (j=0; j++ < 5;) {
                    Data["T-" DPF[j]] = TDP[j];
                }
            } else {
                Data["T-" FFields[i]]=TFields[i];
            }
        }
        ######### DEBUG THE DATA FIELDS ########
        # for (i in Data) {
        #     printf("%s-->%s;",i,Data[i])
        # }
        # print "\n";
        ########################################

        ######### CHANGE INDEL COORDS ############
        # variant is an insertion/complex substitution 
        if (AL > 1) {
            if (RL == 1) { # an insertion
                end=start;
                # if first base is the same 
                # remove the redundant base in Ref and Alt
                if (R == substr(A,1)) {             
                    R="-";
                    A=substr(A,2);
                }
            } else { # is a complex substitution AC -> TG  
                end=start+RL-1;
            }
        # variant is a deletion
        } else if (RL > 1) {
            # is a deletion
            # make the pos of deleted bases to start and end
            start=start+1;
            end=start + RL -2;
            # remove the redundant base in Ref and Alt
            R=substr(R,2);
            A="-";
        } else { # it is a simple SNP
            end = start;
        }

        ######## OUTPUT #################
        # print the first 6 fields
        printf("%s\t%s\t%s\t%s\t%s\t%s",$1,start,end,R,A,Q); # 6 fields
        for (i = 6; i++ < 23;) {
            # pass i through HEADER for the col order
            # 
            printf("\t%s",Data[VCF[HEADER[i]]]);
        }
        printf("\n");
    }
}'




#  NS Type=Integer,Description="Number of samples with data"