args = commandArgs(trailingOnly=TRUE)

input <- read.table(args[1], 
                      header = TRUE, sep = "\t", stringsAsFactors = FALSE)
output <- as.data.frame(matrix(ncol = ncol(input)))
colnames(output) <- colnames(input)

j <- 1
for (i in 1:nrow(input))
{
    if (grepl(",", input[i,5])){
        A <- strsplit(input[i,5], split = ",")[[1]]
        
        for (k in 1:length(A))
        {
            for (z in 1:(ncol(input) - 1))
            {
                tmp <- strsplit(as.character(input[i,z]), split = ",")[[1]]
                if (length(tmp) != 1)
                {
                    output[j,z] <- tmp[k]
                } else {
                    output[j,z] <- tmp[1]
                }
                
            }
            
            tmp <- strsplit(input[i,ncol(input)], split = ",")[[1]]
            
            output[j,ncol(input)] <- paste(tmp[(1 + (k-1)*3):(k*3)], collapse =  ",")
            j = j + 1
        }
            
    } else {

                output[j,] <- input[i,]
        j = j + 1
    }
}

write.table(output, file = args[2], col.names = TRUE, sep = "\t",
            row.names = FALSE, quote = FALSE)