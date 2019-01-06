#!/usr/bin/env RScript

# execute with `./total_amount_ov.R < file.csv`

Sys.setenv(TZ="Europe/Berlin")

data <- read.csv("stdin", sep=";", dec=",")
the_month <- unique(format(as.POSIXlt(data$Datum, format="%d-%m-%Y"), "%b %Y"))
amount <- sum(data$Bedrag)
res <- paste("The total amount for ", the_month, " is ", amount, "€.", sep="")
cat(res, sep="\n")

