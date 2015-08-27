
#Hack to produce running total genome length for each chrom.
chromSizes <- c(197195432, 181748087, 159599783, 155630120, 152537259, 149517037, 152524553, 131738871, 124076172, 129993255, 121843856, 121257530, 120284312, 125194864, 103494974, 98319150, 95272651, 90772031, 61342430, 166650296, 15902555)
names(chromSizes) <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "X", "Y")
chromRunsum <- c(0)
for (i in 1:length(chromSizes)) {
  chromRunsum[i+1] <- sum(chromSizes[1:i])
}
names(chromRunsum) <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "X", "Y", "ALL")

#get files. this is hardcoded, you need to change these file patterns for new analyses.
long_files <- Sys.glob("~/Desktop/Mouse_Test/*.long")
short_files <- Sys.glob("~/Desktop/Mouse_Test/*.cov.norm.num.short")

#need data frame of sister pair long and shorts
for (i in 1:length(long_files)) {
  long <- read.delim(long_files[i], header=FALSE)
  short <- read.delim(short_files[i], header=FALSE)
  
  #Change int ID'ed sex chroms to usual chars.
  long[long$V1 == '20', ]$V1 <- 'X'
  long[long$V1 == '21', ]$V1 <- 'Y'
  
  short[short$V3 == '20', ]$V3 <- 'X'
  short[short$V3 == '21', ]$V3 <- 'Y'
  
  #Add running sum chrom lens to coordinates for linear plot of all chroms.
  #V2 is start position of CNV bin
  for (j in 1:length(long[,1])) {
    chrom <- long[j,1]
    pos <- long[j,2]
    long[j,2] <- pos + chromRunsum[chrom]
  }
  
  
  #Add running sum chrom lens to coordinates for linear plot of all chroms.
  for (j in 1:length(short$V1)) {
    chrom <- short[j,3]
    start_pos <- short[j,4]
    stop_pos <- short[j,5]
    short[j,4] <- start_pos + chromRunsum[chrom]
    short[j,5] <- stop_pos + chromRunsum[chrom]
  }
  
  #produce .png filename for output (or .)\
  filename <- sub(".500kb.cov.norm.num", "", basename(file_path_sans_ext(long_files[i])))
  fullname <- paste("~/Desktop/Mouse_Test/plots/", paste(filename, ".png", sep=""), sep="")
  
  #plot CNV values for each bin
  png(fullname, width=12, height=6, units="in", res=400)
  plot(long$V2, long$V10*2, xlim=c(0,chromRunsum['ALL']), pch='o',cex=0.7,col='navy', xaxt='n', ylab="Diploid Copy Number", xlab="Chromosome", ylim=c(0,6), main=filename)

  #add CBS segment calls from short file
  #need to generate 4 vectors: (x-start, y-start), (x-stop, y-stop)
  x0 <- vector()
  y0 <- vector()
  x1 <- vector()
  y1 <- vector()
  for (j in 1:length(short$V1)) {
    x0[j] <- short[j,4]
    x1[j] <- short[j,5]
    y0[j] <- short[j,9]*2
    y1[j] <- short[j,9]*2
  }
  segments(x0, y0, x1, y1, col='orange', lwd=6)
  
  #drop chromosome divider lines
  for (b in chromRunsum) {
    abline(v=b, col='black', lty='dashed', lwd=1)
  }
  
  label_poslist <- vector()
  for (j in 1:length(chromRunsum)-1) {
    label_poslist[j] <- (chromRunsum[j] + chromRunsum[j+1])/2
  }
  #drop chromosome X labels (need to get vector of midpoints of each chrom)
  axis(side=1, at=label_poslist, labels=names(chromRunsum[1:length(chromRunsum)-1]))
  dev.off()
}
