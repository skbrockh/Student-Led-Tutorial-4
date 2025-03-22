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
mkdir tutorial4
cd tutorial4
```

### **Download Instructions**
Use the SRA Toolkit (must be installed beforehand if run locally, otherwise available in most HPCs) to download paired-end FASTQ files:

   ``` bash
   # Example for a mock-infected sample. More replicates are always better, so repeat step for each SRA    accession.

prefetch --max-size 100G SRR11412215 #Handles large files efficiently (downloads in chunks to avoid corruption) 
fastq-dump --gzip SRR11412215
```
or

   ``` bash
   # Example for a COVID-19-infected sample. More replicates are always better, so repeat step for each SRA accession.
prefetch --max-size 100G SRR11412227
fastq-dump --gzip SRR11412227
```
- Repeat for all replicates
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
-Visualize multiqc file

3. Combine FASTQ files for mock-infected and COVID-19-infected groups:
   ```bash
   cat SRR11412215.fastq SRR11412216.fastq > mock_combined.fastq
   cat SRR11412227.fastq SRR11412228.fastq > covid_combined.fastq
   
#### **Part 2: Run Trinity (MEMORY DEMANDING!)**
1. Run Trinity for de novo transcriptome assembly:
```
salloc --mem=64G --cpus-per-task=32 --time=06:00:00

module load Trinity/2.15.1

Trinity --seqType fq --max_memory 64G \
        --single mock_combined.fastq \
        --CPU 32 --output mock_trinity_out
```

  - Replace mock_combined.fastq with covid_combined.fastq
```
Trinity --seqType fq --max_memory 64G \
        --single covid_combined.fastq \
        --CPU 32 --output mock_trinity_out
```

2. Output:
- Trinity.fasta: Contains assembled transcripts.
- Logs and intermediate files for troubleshooting.

#### **Part 3: Evaluate Assembly Quality**
1. Count the number of transcripts:
   ```bash
   grep -c ">" mock_trinity_out/Trinity.fasta
2. Assess transcript length distribution for mock data:
   ```bash
   mkdir ~/trinity_stats_tool && cd ~/trinity_stats_tool
   git clone https://github.com/trinityrnaseq/trinityrnaseq.git
   cd /ocean/projects/agr250001p/your-username/tutorial4
   perl -I ~/trinity_stats_tool/trinityrnaseq/PerlLib ~/trinity_stats_tool/trinityrnaseq/util/TrinityStats.pl mock_trinity_out.Trinity.fasta > mock_trinity_stats.txt
3. Assess transcript length distribution for mock data:
   ```bash
     perl -I ~/trinity_stats_tool/trinityrnaseq/PerlLib ~/trinity_stats_tool/trinityrnaseq/util/TrinityStats.pl covid_trinity_out.Trinity.fasta > covid_trinity_stats.txt

#### **Part 4: Downstream Analysis**
1. Quantify Transcript Abundance.
  - Use Salmon or RSEM for quantification:
   ```bash
   salmon quant -i mock_trinity_out/Trinity.fasta -l A \
             -1 mock_combined.fastq -2 covid_combined.fastq \
             -o salmon_out
 ```
  - Output:
  - Quantification files indicating transcript abundance.

2. Annotate Transcripts (Optional).
- Predict coding regions using TransDecoder:
   ```bash
   TransDecoder.LongOrfs -t mock_trinity_out/Trinity.fasta
   TransDecoder.Predict -t mock_trinity_out/Trinity.fasta
- Output:
  - Predicted coding sequences and peptide sequences.

#### **Part 5: Data Visualization**
1. Plot transcript length distribution (R example):
   ```R
   library(ggplot2)
   lengths <- read.table("trinity_out/Trinity.fasta.stats", header=TRUE)
   ggplot(lengths, aes(x=Length)) + 
    geom_histogram(binwidth=100) + 
    theme_minimal()
2. Create heatmaps for quantified transcripts (e.g., top 50):
   ```R
   library(pheatmap)
   top_transcripts <- head(order(salmon_out$abundance), 50)
   pheatmap(salmon_out[top_transcripts, ])
