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
  - SRA Accessions: `SRR11412215`, `SRR11412216`, `SRR11412217`, `SRR11412218`.
- **COVID-19-infected cells**:
  - SRA Accessions: `SRR11412227`, `SRR11412228`, `SRR11412229`, `SRR11412230`, `SRR11412231`.

The focus will be on **de novo transcriptome assembly** instead of reference-based alignment.

### **Download Instructions**
1. Use the SRA Toolkit to download paired-end FASTQ files:
   ```bash
   fastq-dump --split-files SRR11412215
   fastq-dump --split-files SRR11412227
2. Repeat the process for all replicates.

### **Tasks and Deliverables**
#### **Part 1: Data Preparation**
1. Verify the quality of RNA-seq reads using FastQC (optional but recommended):
   ```bash
   fastqc SRR11412215_1.fastq SRR11412215_2.fastq

2. Combine FASTQ files for all replicates if necessary (e.g., for mock-infected and COVID-19-infected groups):
   ```bash
   cat SRR11412215_1.fastq SRR11412216_1.fastq > mock_combined_1.fastq
   cat SRR11412215_2.fastq SRR11412216_2.fastq > mock_combined_2.fastq
#### **Part 2: Run Trinity**
1. Run Trinity for de novo transcriptome assembly:
   ```bash
   Trinity --seqType fq --max_memory 16G \
        --left mock_combined_1.fastq --right mock_combined_2.fastq \
        --CPU 8 --output mock_trinity_out
  - Replace mock_combined_1.fastq and mock_combined_2.fastq with filenames for COVID-19-infected data as needed.
2. Output:
- Trinity.fasta: Contains assembled transcripts.
- Logs and intermediate files for troubleshooting.

#### **Part 3: Evaluate Assembly Quality**
1. Count the number of transcripts:
   ```bash
   grep -c ">" mock_trinity_out/Trinity.fasta
2. Assess transcript length distribution:
   ```bash
   TrinityStats.pl mock_trinity_out/Trinity.fasta

#### **Part 4: Downstream Analysis**
1. Quantify Transcript Abundance.
  - Use Salmon or RSEM for quantification:
   ```bash
   salmon quant -i mock_trinity_out/Trinity.fasta -l A \
             -1 mock_combined_1.fastq -2 mock_combined_2.fastq \
             -o mock_salmon_out
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
