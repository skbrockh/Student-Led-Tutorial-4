
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
library(ggplot2)

lengths <- read.table("mock_length_stats.txt", header=TRUE)
ggplot(lengths, aes(x=Length)) + 
 geom_histogram(binwidth=100) + 
 theme_minimal()

if (!requireNamespace("pheatmap", quietly = TRUE)) {
  install.packages("pheatmap")
}
library(pheatmap)

#top_transcripts <- head(order(mock & ), 50)
#pheatmap(salmon_out[top_transcripts, ])
