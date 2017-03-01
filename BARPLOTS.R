library(ggplot2)
library(plyr)
library(scales)

#read sample map info file
smap <- read.delim("./tables/NEW.SCNT.Sample.Map.txt", stringsAsFactors = FALSE)
#change colnames to match indel and snp vcf info fields
colnames(smap) <- c("UNIQ", "ANIMAL", "SOURCE", "EXPT", "CASE", "SEX")

#read indel count table
indel_fnr <- read.delim("./tables/INDEL.FNR.COUNT.tab", stringsAsFactors=FALSE)
colnames(indel_fnr) <- c("UNIQ", "CASE", "COUNT", "HQCOUNT")
#merge with sample map and subset columns
indel_fnr <- merge(indel_fnr, smap)[,c("UNIQ", "CASE", "COUNT", "HQCOUNT", "ANIMAL", "EXPT")]
#get control gss count for each sample
ccounts <- indel_fnr[indel_fnr$CASE=="Control",c("ANIMAL", "COUNT")]
colnames(ccounts) <- c("ANIMAL", "CCOUNT")
#merge counts with fnr dataframe
indel_fnr <- merge(indel_fnr, ccounts)
#calculate FNR rate
indel_fnr$FNR <- 1-indel_fnr$HQCOUNT/indel_fnr$CCOUNT
#read indel calls dataframe
indels <- read.delim("./dataframes/INDEL.SCNT.df", stringsAsFactors=FALSE)
#subset for passing variants
indels_pass <- subset(indels, FILTER=="PASS")
#count calls per sample
indel_count <- count(indels_pass, var=c("ANIMAL", "UNIQ", "CASE"))
#merge with fnr data
indel_count <- merge(indel_count, indel_fnr)
#multiply count by 1+fnr to get estimated total calls
indel_count$ADD <- round(indel_count$freq*(1+indel_count$FNR))
#annotate with Indel type column for plotting vs SNVs
indel_count$TYPE <- "Indel"

#same for SNPs
#read snp FNR table and change colnames
snp_fnr <- read.delim("./tables/snp.FNR.COUNT.tab", stringsAsFactors=FALSE)
colnames(snp_fnr) <- c("UNIQ", "CASE", "COUNT", "HQCOUNT")
#merge with sample map and subset columns
snp_fnr <- merge(snp_fnr, smap)[,c("UNIQ", "CASE", "COUNT", "HQCOUNT", "ANIMAL", "EXPT")]
#get control SNP GSS count for each sample
ccounts <- snp_fnr[snp_fnr$CASE=="Control",c("ANIMAL", "COUNT")]
colnames(ccounts) <- c("ANIMAL", "CCOUNT")
#merge counts with fnrs
snp_fnr <- merge(snp_fnr, ccounts)
#calculate FNR rate
snp_fnr$FNR <- 1-snp_fnr$HQCOUNT/snp_fnr$CCOUNT
#read snp calls dataframe
snps <- read.delim("./dataframes/SNP.SCNT.df", stringsAsFactors=FALSE)
#subset for passing variants
snps_pass <- subset(snps, FILTER=="PASS")
#count calls per sample
snp_count <- count(snps_pass, var=c("ANIMAL", "UNIQ", "CASE"))
#merge with fnr data
snp_count <- merge(snp_count, snp_fnr)
#multiply count by fnr to get estimated total count
snp_count$ADD <- round(snp_count$freq*(1+snp_count$FNR))
#annotate as snps
snp_count$TYPE <- "SNP"

#catenate indel and snp count dfs
counts <- rbind(indel_count, snp_count)
#remove sample C1
counts <- subset(counts, UNIQ!="C1")

#change type to factor and then re-order (to get dodged bar order like i want)
counts$TYPE <- factor(counts$TYPE)
counts$TYPE <- factor(counts$TYPE, levels=rev(levels(counts$TYPE)))

#set colors for plot groups (SNP, Indel, SV, MEI)
colors <- c("black", "red", "black", "red")

#SCNT counts, color by Indel/SNP
p1 <- ggplot(subset(counts, CASE=="SCNT"), aes(x=UNIQ, group=TYPE)) +
  geom_bar(aes(y=ADD), 
          col="black",
          stat="identity",
          position=position_dodge(0.6),
          width=0.6,
          alpha=0) +
  geom_bar(aes(y=freq, fill=TYPE),
          col="black",
          stat="identity",
          position=position_dodge(0.6),
          width=0.6) +
  facet_grid(~EXPT,
          scale="free_x",
          space="free_x") +
  xlab("Sample") + 
  ylab("Count") +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  geom_hline(yintercept=0)

ggsave("../outputs/SNP_INDEL.pdf", p1, width=8, height=5, units="in")

# ggplot(snps, aes(x=UAB))

###Plot SVs and MEIs
#read SV counts table
SVs <- read.delim("./tables/SV.SCNT.counts.tab", stringsAsFactors = FALSE)
#merge with sample map
SVs <- merge(SVs, smap, all=TRUE)
#set colnames to match
colnames(SVs) <- c("UNIQ", "freq", "ANIMAL", "SOURCE", "EXPT", "CASE", "SEX")
#subset cols
SVs <- SVs[,c("ANIMAL", "freq", "CASE", "UNIQ", "EXPT")]
SVs$TYPE <- "SV"

#set missing samples to 0
# SVs[is.na(SVs)] <- 0

#read mei calls dataframe
MEIs <- read.delim("./dataframes/MEI.SCNT.df", stringsAsFactors = FALSE)
#count calls per sample
MEIs <- count(MEIs, var=c("ANIMAL", "UNIQ", "CASE"))
#merge with sample map
MEIs <- merge(MEIs, smap, all=TRUE)
#subset cols
MEIs <- MEIs[,c("ANIMAL", "freq", "CASE", "UNIQ", "EXPT")]
#annotate as MEI count
MEIs$TYPE <- "MEI"


#bind with SV counts table
both <- rbind(SVs, MEIs)
#get just SCNTs
both <- subset(both, CASE=="SCNT")

#remove sample C1
both <- subset(both, UNIQ!="C1")

#change type to factor and then re-order (to get dodged bar order like i want)
both$TYPE <- factor(both$TYPE)
both$TYPE <- factor(both$TYPE, levels=rev(levels(both$TYPE)))

p2 <- ggplot(both, aes(x=UNIQ)) +
  geom_bar(aes(y=freq, fill=TYPE),
          stat="identity", 
          col="black", 
          position=position_dodge(0.6), 
          width=0.6) +
  facet_grid(~EXPT, 
          scales="free_x", 
          space="free_x") + 
  xlab("Sample") + 
  ylab("Count") +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  geom_hline(yintercept=0)

ggsave("../outputs/SV_MEI.pdf", p2, width=8, height=5, units="in")

#reformat colnames for spreadsheet output
colnames(snp_count) <- c("ANIMAL", "UNIQ", "CASE", "SNVs", "COUNT", "HQCOUNT", "EXPT", "CCOUNT", "SNVFNR", "EstimatedSNVs", "TYPE")
colnames(indel_count) <- c("ANIMAL", "UNIQ", "CASE", "Indels", "COUNT", "HQCOUNT", "EXPT", "CCOUNT", "IndelFNR", "EstimatedIndels", "TYPE")

#subset columns
snp_count <- snp_count[,c("ANIMAL","UNIQ","CASE","SNVs","EXPT","SNVFNR","EstimatedSNVs")]
indel_count <- indel_count[,c("ANIMAL","UNIQ","CASE","Indels","EXPT","IndelFNR","EstimatedIndels")]

#subset columns
SVs <- SVs[c(1,2,3,4)]
colnames(SVs) <- c("ANIMAL", "SVs", "CASE", "UNIQ")

#subset columns
MEIs <- MEIs[c(1,2,3,4)]
colnames(MEIs) <- c("ANIMAL", "MEIs", "CASE", "UNIQ")

#merge snp and indel count cols
snpdels <- merge(snp_count, indel_count)
#merge sv and mei count cols
svmeis <- merge(SVs, MEIs)
#merge both into full output
chart <- merge(snpdels, svmeis)
chart[is.na(chart)] <- 0
#get sum of variant calls per sample
chart$TOTAL <- chart$EstimatedSNVs + chart$EstimatedIndels + chart$SVs + chart$MEIs
#reformat FNRs to percentages
chart$IndelFNR<-percent(chart$IndelFNR)
chart$SNVFNR<-percent(chart$SNVFNR)

#write output
write.table(chart, "../outputs/SUMMARY.tab", sep="\t", row.names = FALSE, quote = FALSE)

both$SET <- "SV/MEI"
both$ADD <- NA
counts <- counts[,c("ANIMAL", "freq", "CASE", "UNIQ", "TYPE", "ADD", "EXPT")]
counts$SET <- "SNP/Indel"

full <- rbind(counts, both)
full <- subset(full, CASE=="SCNT")

p3 <- ggplot(full, aes(x=UNIQ, group=TYPE)) +
  geom_bar(aes(y=ADD), 
          col="black", 
          stat="identity", 
          position=position_dodge(0.6), 
          width=0.6, 
          alpha=0) +
  geom_bar(aes(y=freq, fill=TYPE), 
          col="black", 
          stat="identity", 
          position=position_dodge(0.6), 
          width=0.6) +
  facet_grid(SET~EXPT, 
          scale="free", 
          space="free_x") + 
  xlab("Sample") + 
  ylab("Count") +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  geom_hline(yintercept=0)

ggsave("../outputs/ALL.pdf", p3, width=8, height=10, units="in")


hets1 <- read.delim("./dataframes/HET.ABS.df", stringsAsFactors=FALSE)
colnames(hets1) <- c("UAB")
hets1$CONF <- "SNP"
hets2 <- hets1
hets1$EXPT<-"MT"
hets2$EXPT<-"ROD"
hets <- rbind(hets1, hets2)


snps$CONF <- NA
snps$CONF[grepl("VQSR", snps$FILTER) & !grepl("MGP", snps$FILTER)] <- "LC SNVS"
snps$CONF[!grepl("VQSR|MGP", snps$FILTER)] <- "HC SNVS"
snps$CONF[grepl("MGP", snps$FILTER)] <- "MGP"

#remove MGP and allosome calls
dist <- subset(snps, CONF!="MGP")
dist <- subset(dist, CHROM!="X")
dist <- subset(dist, CHROM!="Y")

p4 <- ggplot(dist, aes(x=UAB)) +
  geom_density(aes(col=CONF)) +
  geom_density(data=hets, aes(x=UAB, col=CONF), adjust=3) +
  facet_grid(~EXPT) +
  geom_vline(xintercept=0.3, col="red") +
  xlab("VAF") + ylab("Density")

ggsave("../outputs/DIST.pdf", p4, width=10, height=5, units="in")