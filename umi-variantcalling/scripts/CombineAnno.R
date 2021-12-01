#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

out <- read.table(args[1], header = TRUE, sep = "\t",
                   stringsAsFactors = FALSE)


primer <- read.table(args[2], header = TRUE, sep = "\t",
                     stringsAsFactors = FALSE)
primer <- primer[!duplicated(primer[,1:3]),]

hdr <- read.table(args[3], header = TRUE, sep = "\t",
                     stringsAsFactors = FALSE)

out <- merge(out, hdr, by.x = c("Chr",  "Start", "End", "Ref", "Alt", "Gene"),
              by.y = c("Chr", "Start", "End", "Ref", "Alt", "Gene"))
out <- merge(out, primer, by.x = c("Chr",  "Start", "End", "Ref", "Alt", "Gene"),
              by.y = c("Chr", "Start", "End", "Ref", "Alt", "Gene"), all.x = TRUE)

write.table(out, file = args[4], quote = TRUE, sep = "\t", row.names = FALSE)