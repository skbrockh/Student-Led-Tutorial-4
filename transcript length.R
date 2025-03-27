#Install and load libraries
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
library(ggplot2)

# Read the text files
mock_lines <- readLines("mock_trinity_stats.txt")
covid_lines <- readLines("covid_trinity_stats.txt")

# Extract average and median contig lengths
get_stat <- function(pattern, lines) {
  value <- grep(pattern, lines, value = TRUE)
  as.numeric(gsub("[^0-9.]", "", value))
}

mock_avg <- get_stat("Average contig", mock_lines)
mock_med <- get_stat("Median contig length", mock_lines)

covid_avg <- get_stat("Average contig", covid_lines)
covid_med <- get_stat("Median contig length", covid_lines)

#Create a dataframe for plotting
length_stats <- data.frame(
  Condition = rep(c("Mock", "COVID"), each = 2),
  Metric = rep(c("Average", "Median"), times = 2),
  Value = c(mock_avg, mock_med, covid_avg, covid_med)
)

#Create a barplot
ggplot(length_stats, aes(x = Metric, y = Value, fill = Condition)) +
  geom_col(position = "dodge") +
  theme_minimal() +
  labs(title = "Transcript Length Comparison (Summary)",
       y = "Length (bp)")
