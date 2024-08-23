#!/usr/bin/env Rscript
print("start MergCalls")
args = commandArgs(trailingOnly=TRUE)
print(args[1])
print(args[2])

files <- list.files(args[1], pattern = ".edit.csv")

n = 0
out <- ""
for (i in 1:length(files)) 
{
    sample <- strsplit(files[i], split = ".", fixed = TRUE)[[1]][1]  
    #print(sample)
    file <- read.table(paste0(args[1], "/", files[i]),
                       header = TRUE,
                       quote = "\"", 
                       sep = "\t",
                       stringsAsFactors = FALSE)
    n = n + nrow(file)
    file <- cbind(Sample = sample, file)
    
    if (i == 1)
    {
        out <- file
    } else {
        out <- rbind(out, file)
    }
} 

print("write Table \n")
write.table(out, file = args[2], quote = TRUE, sep = "\t", row.names = FALSE)
print("MergCalls done")
