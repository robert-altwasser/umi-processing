args = commandArgs(trailingOnly=TRUE)

input <- read.table(args[1],
                    sep = "\t", header = FALSE, stringsAsFactors = FALSE)

out <- as.data.frame(matrix(ncol = 23, nrow = nrow(input)))
colnames(out) <- c("Chr", "Start", "End", "Ref", "Alt", "Qual", "readDepth",
                   "TR1", "TR1_plus", "TR1_minus", "TR2", "TR2_plus", "TR2_minus",
                   "Qual1", "Qual2", "MQ1", "MQ2", "StrandBalance1", "StrandBalance2",
                   "FreqPaired1", "FreqPaired2", "AlleleType", "FGL")
out[,1] <- input[,1]
out[,2] <- input[,2]
out[,3] <- input[,2] + nchar(input[,4]) - 1
out[,4] <- input[,4]
out[,5] <- input[,5]
out[,6] <- input[,6]

for (i in 1:nrow(input))
{
    tmp <- stringr::str_split(input[i,10], pattern = ":")[[1]]
    
    out[i,7] <- as.integer(tmp[2])
    
    out[i,8] <- as.integer(stringr::str_split(tmp[4], pattern = ",")[[1]][1]) 
    out[i,11] <- as.integer(stringr::str_split(tmp[4], pattern = ",")[[1]][2])

    out[i,9] <- as.integer(stringr::str_split(tmp[6], pattern = ",")[[1]][1]) 
    out[i,10] <- as.integer(stringr::str_split(tmp[6], pattern = ",")[[1]][2])    

    out[i,12] <- as.integer(stringr::str_split(tmp[7], pattern = ",")[[1]][1]) 
    out[i,13] <- as.integer(stringr::str_split(tmp[7], pattern = ",")[[1]][2]) 
    
    out[i,18] <- out[i,9]/out[i,8]
    out[i,19] <- out[i,12]/out[i,11]
    
}

write.table(out, file = args[2], quote = FALSE, row.names = FALSE, sep = "\t")
