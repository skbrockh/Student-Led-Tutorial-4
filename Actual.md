# Student-Led-Tutorial-4
# Task: Tutorial for De Novo Transcriptome Assembly Using Trinity
# Date: March 27th

## **Objective**
Students will:
1. Understand the purpose and applications of de novo transcriptome assembly.
2. Assemble transcripts from RNA-seq data using **Trinity**.
3. Evaluate the quality of assembled transcripts.
4. Perform optional downstream analyses such as transcript quantification and annotation.

---
## **Software and Manuals**
### **Required Software**
1. **Trinity**: De novo RNA-seq assembler.  
   - [Trinity GitHub Repository](https://github.com/trinityrnaseq/trinityrnaseq)
   - [Installation Instructions](https://github.com/trinityrnaseq/trinityrnaseq/wiki)
2. **SRA Toolkit**: To download RNA-seq data from SRA.  
   - [SRA Toolkit Documentation](https://github.com/ncbi/sra-tools)
3. **FastQC**: For quality control of RNA-seq reads.  
   - [FastQC Website](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
4. **Samtools**: For sequence data manipulation.  
   - [Samtools Documentation](http://www.htslib.org/doc/)
5. **Salmon** or **RSEM**: For transcript quantification (optional).  
   - [Salmon GitHub Repository](https://github.com/COMBINE-lab/salmon)
   - [RSEM GitHub Repository](https://github.com/deweylab/RSEM)
6. **TransDecoder**: For identifying coding regions in transcripts.  
   - [TransDecoder GitHub Repository](https://github.com/TransDecoder/TransDecoder)
7. **R and RStudio**: For downstream analysis and visualization.  
   - [R Project](https://www.r-project.org/)
   - [RStudio Website](https://posit.co/downloads/)

---

## **Dataset Description**
We will use the same RNA-seq dataset as in the STAR tutorial:
- **Mock-infected cells**:
  - SRA Accessions: `SRR11412215`, `SRR11412216`
- **COVID-19-infected cells**:
  - SRA Accessions: `SRR11412227`, `SRR11412228`

The focus will be on **de novo transcriptome assembly** instead of reference-based alignment.

### Make sure you go to your ocean folder
```
myocean
```
### Clone the Repository
```
git clone

```
```
cd Student-Led-Tutorial-4
mkdir tutorial4
cd tutorial4
```
### **Download Instructions**
Use the SRA Toolkit (must be installed beforehand if run locally, otherwise available in most HPCs) to download paired-end FASTQ files:

   ``` bash
   # Example for a mock-infected sample. More replicates are always better, so repeat step for each SRA    accession.
# Example for a COVID-19-infected sample. More replicates are always better, so repeat step for each SRA accession.


module load sra-toolkit
prefetch --max-size 100G SRR11412215 #Handles large files efficiently (downloads in chunks to avoid corruption) 
fastq-dump --gzip SRR11412215

prefetch --max-size 100G SRR11412216
fastq-dump --gzip SRR11412216

prefetch --max-size 100G SRR11412227
fastq-dump --gzip SRR11412227

```
### **Tasks and Deliverables**
#### **Part 1: Data Preparation**
1. Verify the quality of RNA-seq reads using FastQC (optional but recommended):
   ```bash
   module load FastQC
   fastqc -t 4 *.fastq -o fastqc_data_out
2. Run multiqc
```
module load python/3.8.6
multiqc --dirs fastqc_data_out --filename multiqc_raw_data.html
```
-Visualize multiqc file with QIIME 2.
```
git add multiqc_raw_data.html
git commit -m "multiqc data"
git push
```

3. Combine FASTQ files for mock-infected and COVID-19-infected groups:
   ```bash
   cat SRR11412215.fastq SRR11412216.fastq > mock_combined.fastq
   cat SRR11412227.fastq SRR11412228.fastq > covid_combined.fastq
   
#### **Part 2: Run Trinity (MEMORY DEMANDING!)**
1. Run Trinity for de novo transcriptome assembly:
```
salloc --mem=256G --cpus-per-task=128 --time=06:00:00

module load Trinity/2.15.1

Trinity --seqType fq --max_memory 256G \
        --single mock_combined.fastq \
        --CPU 128 --output mock_trinity_out
```

  - Replace mock_combined.fastq with covid_combined.fastq
```
Trinity --seqType fq --max_memory 256G \
        --single covid_combined.fastq \
        --CPU 128 --output covid_trinity_out
```

2. Output:
- Trinity.fasta: Contains assembled transcripts.
- Logs and intermediate files for troubleshooting.

#### **Part 3: Evaluate Assembly Quality**
1. Count the number of transcripts:
   ```bash
   grep -c ">" mock_trinity_out.Trinity.fasta
   grep -c ">" covid_trinity_out.Trinity.fasta

2. Assess transcript length distribution for mock data:
   ```bash
   mkdir ~/trinity_stats_tool && cd ~/trinity_stats_tool
   git clone https://github.com/trinityrnaseq/trinityrnaseq.git
   cd /ocean/projects/agr250001p/your-username/Student-Led-Tutorial-4/tutorial4
   perl -I ~/trinity_stats_tool/trinityrnaseq/PerlLib ~/trinity_stats_tool/trinityrnaseq/util/TrinityStats.pl mock_trinity_out.Trinity.fasta > mock_trinity_stats.txt
3. Assess transcript length distribution for covid data:
   ```bash
     perl -I ~/trinity_stats_tool/trinityrnaseq/PerlLib ~/trinity_stats_tool/trinityrnaseq/util/TrinityStats.pl covid_trinity_out.Trinity.fasta > covid_trinity_stats.txt

#### **Part 4: Downstream Analysis**
- Use Salmon for quantification:
1. Create a conda environment to install salmon and activate the environment
```
module load anaconda3
```
```
conda create -n salmon_env -c bioconda -c conda-forge salmon
```
```
conda activate salmon_env
```
3. Create salmon index (Yes, one index for both)
```
salmon index -t mock_trinity_out.Trinity.fasta -i mock_trinity_index
```
3. Quantify Transcript Abundance.
- For mock:
```bash
   salmon quant -i mock_trinity_index -l A \
       -r mock_combined.fastq \
       -o salmon_mock_out
```
- For  covid:
```bash
   salmon quant -i mock_trinity_index -l A \
       -r covid_combined.fastq \
       -o salmon_covid_out
```
- Output:
- Quantification files indicating transcript abundance.

#### **Part 5: Data Visualization in R**
#### TRANSCRIPT LENGHT COMPARISON
1. Plot transcript length distribution (R example):
```
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

```
#### TRANSCRIPT LENGHT COMPARISON
```
#Install and load libraries
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

if (!requireNamespace("Biostrings", quietly = TRUE)) {
  BiocManager::install("Biostrings")
}
library(Biostrings)

# Read FASTA files
mock_fa <- readDNAStringSet("mock_trinity_out.Trinity.fasta")
covid_fa <- readDNAStringSet("covid_trinity_out.Trinity.fasta")

# Get transcript lengths
mock_lengths <- data.frame(Length = width(mock_fa), Condition = "Mock")
covid_lengths <- data.frame(Length = width(covid_fa), Condition = "COVID")

# Combine into one dataframe
all_lengths <- rbind(mock_lengths, covid_lengths)

# Plot Transcript Length Distribution
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
library(ggplot2)

#Create plot
ggplot(all_lengths, aes(x=Length, color=Condition, fill=Condition)) +
  geom_density(alpha=0.3) +
  scale_x_continuous(limits=c(0, 5000)) +  # optional: limit x-range
  scale_fill_manual(values=c("Mock"="#0072B2", "COVID"="#D55E00")) +
  scale_color_manual(values=c("Mock"="#0072B2", "COVID"="#D55E00")) +
  theme_minimal() +
  labs(title="Transcript Length Distribution",
       x="Transcript Length (bp)",
       y="Density")
```
#### COMPARE TRANSCRIPT EXPRESSION
1. Prepare transcript-to-gene map in the HPC
```
grep ">" mock_trinity_out.Trinity.fasta | sed 's/>//' | \
awk -F ' ' '{print $1}' | \
awk -F '_' '{OFS=","; print $0, $1"_"$2"_"$3"_"$4}' > tx2gene.csv
```
2. Create a heatmap R
```
#Install and load libraries
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("tximport")
library(tximport)

if (!requireNamespace("pheatmap", quietly = TRUE)) {
  install.packages("pheatmap")
}
library(pheatmap)

# Point to Salmon quant files
files <- c("mock" = "quant_mock.sf",
           "covid" = "quant_covid.sf")

# Load tx2gene
tx2gene <- read.csv("tx2gene.csv", header=FALSE, col.names=c("TXNAME", "GENEID"))

# Import data
txi <- tximport(files, type="salmon", tx2gene=tx2gene)

# Optional: view matrix of expression
head(txi$abundance)

# Get top 50 most expressed transcripts
top_tx <- head(order(rowSums(txi$abundance), decreasing=TRUE), 50)
top_data <- log2(txi$abundance[top_tx, ] + 1)

##Create heatmaps for quantified transcripts (e.g., top 50):
pheatmap(top_data,
         cluster_rows=TRUE,
         cluster_cols=FALSE,
         scale="row",
         fontsize=8,
         main="Top 50 Expressed Transcripts",
         color=colorRampPalette(c("navy", "white", "firebrick3"))(50))
```
