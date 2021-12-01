#!/usr/bin/awk -f
BEGIN {
    OFS="\t";
    CUMSUM=0;
    CUMFREQ=0.0;
    TOTALONTARGET=0;
}
/^all/ {
    CUMSUM=CUMSUM+$3;
    CUMFREQ=(100*CUMSUM/$4);
    TOTALONTARGET = TOTALONTARGET+($2*$3);
    print $0,CUMSUM,CUMFREQ,TOTALONTARGET;
}


