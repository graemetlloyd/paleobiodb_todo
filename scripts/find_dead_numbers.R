# This script updates the dead values for certain database datatypes so other scripts can avoid when to querying data

# Set increment size (queries will be split into this many blocks):
IncrementSize <- 1000

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
  
  # Set the maximum value (most rcenetly entered):
  MaxValue <- MostRecents[[i]]$max
  
  # Find any bad numbers (no record at that address):
  BadNumbers <- unlist(lapply(
    as.list(1:ceiling(MaxValue / IncrementSize)),
    function(x) {
      Request <- ((x * IncrementSize) - IncrementSize + 1):(x * IncrementSize);
      Request <- Request[Request <= MaxValue];
      Query <- readLines(paste0(MostRecents[[i]]$url, paste(Request, collapse = ",")));
      Request[is.na(match(paste0(MostRecents[[i]]$match, Request), gsub("\"", "", unlist(strsplit(gsub("var:", "txn:", Query), split = ",|:\"")))))]
    }
  ))
  
  # Write out abd numbers to file:
  write.table(matrix(BadNumbers, ncol = 1), paste0("~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/bad_", i, "_numbers.txt"))
  
  # Let user know how far you have gotten:
  cat(i)

}
