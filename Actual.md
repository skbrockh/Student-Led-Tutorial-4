Skip to content
Navigation Menu
biologysvsu
Student-Led-Tutorial-4

Code
Issues
Pull requests
Actions
Projects
Wiki
Security
Insights
Settings
Student-Led-Tutorial-4
/
README.md
in
main

Edit

Preview
Indent mode

Spaces
Indent size

2
Line wrap mode

Soft wrap
Editing README.md file contents
Selection deleted
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
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
        --CPU 64 --output mock_trinity_out
Use Control + Shift + m to toggle the tab key moving focus. Alternatively, use esc then tab to move to the next interactive element on the page.
No file chosen
Attach files by dragging & dropping, selecting or pasting them.
Editing Student-Led-Tutorial-4/README.md at main · biologysvsu/Student-Led-Tutorial-4
 
