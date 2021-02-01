# sam-dup-align-exclude.pl version 1.0
## Description
From the sam files (pair-end reads) produced by Bowtie2  
\- Aligned reads are sorted based on 'AS' and 'XS' scores. AS represents alignment score at the reported locus and XS represents score for the best-scoring alignment other than reported one.<br>
\- Unique alignment (no XS tag) and best alignment (either in alignment R1 or R2, AS score is greater than XS) are outputted into the 'a1.sam' file.  
\- Reads which are aligned more than one locus with same alignment scores are outputted into the 'dup.sam' file.
## Command
sam-dup-align-exclude.pl -i [xxx.sam]
## Options
--input:        the inputting sam file (required)  
## Example
sam-dup-align-exclude.pl -i chip-seq.sam
