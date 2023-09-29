# MetagenomeWorkflow_Temp
Temporary repo for my metagenome analysis workflow

The following procedure step numbers correspond to the scripts used for those steps.

| Procedure    | Program |
| -------- | ------- |
| 0. Upload files to Cluster | --- |
| 1. Check sequence quality | FastQC, eestats2 |
| 2. Trim adapters & indexes | BBDuk |
| 3. Merge F/R Reads | BBMerge *(not necessary) |
| 4. Normalize Reads | BBNorm (use trimmed, non-merged reads) |
| 5. Read error correction | Spades |
| 6. Assemble Contigs | Megahit, MetaSpades |
| 7. Check quality of contigs | MetaQUAST |
| 8. Map trimmed, non-normalized reads to contigs | BWA-mem |
| 9. Bin contigs into MAGs | MetaBAT2 |
| 10. Check bin completeness & quality | Check-M |
| 11. Predict genes in contigs & MAGs | Prodigal |
| 12. Annotate Predicted Genes | KOFamScan, eggNOGMapper |
| 13. Taxonomic Annotation of MAGs | GTDB-tk |
| 14. Calculate gene coverage | featureCounts |
| 15. Combine gene coverage & gene functions for each bin & contigs | Custom scripts |
| 16. Identify metabolic pathways | KEGGdecoder, KEGGmapper |

For step 15:
1. Parse featureCounts results to keep only data (i.e., columns) we want, & convert to txt file (and add sample name into file)
> A. Rename contigs in featureCounts file to match KOFamScan results
> > A1. Geneid, chromosome ID
> 
> B. Add column to parsed featureCounts files so we have bin &/or original sample information in file
2. Merge parsed KO ID file with parsed featureCounts so we have coverage for each gene & its functional annotation
3. Combined all results from each bin/set of contigs into a single file

