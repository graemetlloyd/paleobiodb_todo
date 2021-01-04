# This script finds any orphaned taxa (those without a parental assignment) in the database:

# Set Increment size (the number of taxa to ask for at a time):
IncrementSize <- 10000

# Iport current most recently entered taxon (max value):
CurrentLargestTaxonNumber <- read.table("~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/max_vals.txt")["taxon", ]

# Import any bad taxon numbers that have not record associated with them:
BadNumbers <- read.table("~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/bad_taxon_numbers.txt")[, 1]

# Query database for each taxon:
x <- metatree::PaleobiologyDBTaxaQuerier(taxon_nos = as.character(setdiff(1:CurrentLargestTaxonNumber, BadNumbers)), stopfororphans = FALSE, breaker = IncrementSize)

# Reduce to just taxa with no parent assigned:
Orphans <- x[is.na(x[, "ParentTaxonNo"]), ]

# Exclude invalid taxa:
Orphans <- Orphans[is.na(Orphans[, "TaxonValidity"]), ]

# Write out to file:
write.table(Orphans, "~/Documents/Packages/paleobiodb_todo/paleobiodb_todo/data/orphans.txt")
