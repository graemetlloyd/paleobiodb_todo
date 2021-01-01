IncrementSize <- 10000

MostRecents <- list(
  collection = list(max = 216942, url = "https://paleobiodb.org/data1.2/colls/list.json?coll_id=", match = "col:"),
  occurrence = list(max = 1541750, url = "https://paleobiodb.org/data1.2/occs/list.json?id=", match = "occ:"),
  opinion = list(max = 817986, url = "https://paleobiodb.org/data1.2/opinions/list.json?id=", match = "opn:"),
  reference = list(max = 75017, url = "https://paleobiodb.org/data1.2/refs/list.json?ref_id=", match = "ref:"),
  taxon = list(max = 431560, url = "https://paleobiodb.org/data1.2/taxa/list.json?id=", match = "txn:")
)

for(i in names(CurrentMostRecent)) {
  
  ReferenceRequests <- (floor(MostRecents[[i]]$max / 10) * 10) + seq(from = 0, to = IncrementSize - 1, length.out = IncrementSize)
  ReferenceQuery <- gsub("var:", "txn:", readLines(paste0(MostRecents[[i]]$url, paste(ReferenceRequests, collapse = ","))))
  ReferenceNumbers <- ReferenceRequests[which(!is.na(match(paste0(MostRecents[[i]]$match, ReferenceRequests), gsub("\"", "", unlist(as.list(unlist(strsplit(ReferenceQuery, split = ",|:\""))))))))]
  
  while(max(ReferenceNumbers) == max(ReferenceRequests)) {
    
    ReferenceRequests <- (floor((max(ReferenceNumbers) + 1) / 10) * 10) + seq(from = 0, to = IncrementSize - 1, length.out = IncrementSize)
    ReferenceQuery <- gsub("var:", "txn:", readLines(paste0(MostRecents[[i]]$url, paste(ReferenceRequests, collapse = ","))))
    ReferenceNumbers <- ReferenceRequests[which(!is.na(match(paste0(MostRecents[[i]]$match, ReferenceRequests), gsub("\"", "", unlist(as.list(unlist(strsplit(ReferenceQuery, split = ",|:\""))))))))]

  }
  
  MostRecents[[i]]$max <- max(ReferenceNumbers)
  
  cat(paste0(i, max(ReferenceNumbers)))
  
}
