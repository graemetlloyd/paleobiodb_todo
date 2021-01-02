# This script updates the maximum values for certain database datatypes so other scripts can use these to query all available data

# Set increment size (the larger the value the quicker it will find the right value), should be a multiple of ten:
IncrementSize <- 10000

# Build most recently entered data type list:
MostRecents <- list(
  collection = list(max = read.table("~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/max_vals.txt")["collection", ], url = "https://paleobiodb.org/data1.2/colls/list.json?coll_id=", match = "col:"),
  occurrence = list(max = read.table("~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/max_vals.txt")["occurrence", ], url = "https://paleobiodb.org/data1.2/occs/list.json?id=", match = "occ:"),
  opinion = list(max = read.table("~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/max_vals.txt")["opinion", ], url = "https://paleobiodb.org/data1.2/opinions/list.json?id=", match = "opn:"),
  reference = list(max = read.table("~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/max_vals.txt")["reference", ], url = "https://paleobiodb.org/data1.2/refs/list.json?ref_id=", match = "ref:"),
  taxon = list(max = read.table("~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/max_vals.txt")["taxon", ], url = "https://paleobiodb.org/data1.2/taxa/list.json?id=", match = "txn:")
)

# For each type of data:
for(i in names(MostRecents)) {
  
  # Set requests (values to ask database for):
  Requests <- (floor(MostRecents[[i]]$max / 10) * 10) + seq(from = 0, to = IncrementSize - 1, length.out = IncrementSize)
  
  # The actual query result the database returns:
  Query <- gsub("var:", "txn:", readLines(paste0(MostRecents[[i]]$url, paste(Requests, collapse = ","))))
  
  # The requested numbers actually found in the database query:
  Values <- Requests[which(!is.na(match(paste0(MostRecents[[i]]$match, Requests), gsub("\"", "", unlist(as.list(unlist(strsplit(Query, split = ",|:\""))))))))]
  
  # Whilst there may be a larger value not previously in teh request value set:
  while(max(Values) == max(Requests)) {
    
    # Up request values to larger range to potentially cover the maximum (most recent) value:
    Requests <- (floor((max(Values) + 1) / 10) * 10) + seq(from = 0, to = IncrementSize - 1, length.out = IncrementSize)
    
    # The actual query result the database returns:
    Query <- gsub("var:", "txn:", readLines(paste0(MostRecents[[i]]$url, paste(Requests, collapse = ","))))
    
    # The requested numbers actually found in the database query:
    Values <- Requests[which(!is.na(match(paste0(MostRecents[[i]]$match, Requests), gsub("\"", "", unlist(as.list(unlist(strsplit(Query, split = ",|:\""))))))))]

  }
  
  # Update the most recent value to the new maximum:
  MostRecents[[i]]$max <- max(Values)
  
  # Output position in loop to reduce user anxiety:
  cat(paste0(i, max(Values)))
  
}

# Update maximum values data file ready for use by ther scripts:
write.table(matrix(unlist(lapply(MostRecents, function(x) x$max)), ncol = 1, dimnames = list(names(MostRecents), "max_val")), "~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/max_vals.txt")
