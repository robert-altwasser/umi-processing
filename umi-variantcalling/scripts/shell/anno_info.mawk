#!/bin/sh

mawk '
NR == 1 {
    header = $0
    # DATA-fields --> HEADERS
    # + these fields from the vcf-tags
    HEADER[1] = "MutQual";
    HEADER[2] = "readDepth";
    HEADER[3] = "TR1";
    HEADER[4] = "TR1+";
    HEADER[5] = "TR1-";
    HEADER[6] = "TR2";
    HEADER[7] = "TR2+";
    HEADER[8] = "TR2-";
    HEADER[9] = "Qual1";
    HEADER[10] = "Qual2";
    HEADER[11] = "MQ1";
    HEADER[12] = "MQ2";
    HEADER[13] = "StrandBalance1";
    HEADER[14] = "StrandBalance2";
    HEADER[15] = "FreqPaired1";
    HEADER[16] = "FreqPaired2";
    HEADER[17] = "AlleleType";
    HEADER[18] = "FGL";

    ######## HEADER #############
    # remove the .refGene
    for (i = 6; i++ < 11;) {
        sub(".refGene", "", header);
    }
    expanded_info = HEADER[5]
    for (i = 0; i++ < 18;) {
        sub("Otherinfo" i, HEADER[i], header);
    }
    
    print header;
}

NR > 1 {
    print $0
}'