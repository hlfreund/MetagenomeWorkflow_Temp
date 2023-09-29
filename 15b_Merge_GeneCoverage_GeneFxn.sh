#!/bin/bash -l

# script for merging results from featureCounts and KOFamScan based on matching gene IDs found in both featureCounts and KOFamScan outputs
# results from both programs have been parsed
# KOFamScan results only include best gene assignments (see 15a_Parse_KOFamScan script by Mike Lee)

for i in *_parsed_fC_cov.txt;
do
    f=$(basename $i)
    SAMPLE=${f%_parsed*}
    OGSample=${f%_bin*}
    
    if [[ ${SAMPLE} == *"bin".* ]]; then
        awk 'BEGIN {FS=OFS="\t"} NR==FNR {a[$2]=$3 FS $4;next} FNR>1 ($1 in a) {print $1, $2, $3, a[$1] }' ${i} ${SAMPLE}_filter_fxns.txt > ${SAMPLE}_gene_fxns_cov_counts.txt
        awk -i inplace -F '\t' -v A="$OGSample" -v B="$SAMPLE" '{OFS="\t"} NR==1{$0=$0 "\t" "SampleID" "\t" "Bin_ID";} NR>1{$(NF+1)=A;$(NF+2)=B}1 ' ${SAMPLE}_gene_fxns_cov_counts.txt
        
    else

        awk 'BEGIN {FS=OFS="\t"} NR==FNR {a[$2]=$3 FS $4;next} FNR>1 ($1 in a) {print $1, $2, $3, a[$1] }' ${i} SSD_CoAssembly_filter_fxns.txt > ${SAMPLE}_gene_fxns_cov_counts.txt
        awk -i inplace -F '\t' -v A="$SAMPLE" '{OFS="\t"} NR==1{$0=$0 "\t" "SampleID";} NR>1{$(NF+1)=A;}1 ' ${SAMPLE}_gene_fxns_cov_counts.txt
    fi
done

# Notes
# a[$1]= $3 --> in new array a, in field one ($1), this will equal field 3 ($3) of the first input file into awk
# a[$2]= $4 --> in new array a, its field 2 ($2) will equal field 4 ($4) of the first input file into awk
# FNR refers to the record number (typically the line number) in the current file.
# NR refers to the total record number aka how many total lines its processed in all files read by awk
# The operator == is a comparison operator, which returns true when the two surrounding operands are equal.
## This means that the condition NR==FNR is normally only true for the first file, as FNR resets back to 1 for the first line of each file but NR keeps on increasing. We are now just resetting this every time so each file is treated as the first file in the loop
# FNR == 1 --> first line of first file; works for every file because NR=FNR
# FNR > 1 --> for lines beyond line 1
# $1 in a --> if field 1 in second input file matches anything in array a
# print $1, $2, $3 --> print 1, 2, 3 fields of second input file
# print a[$1], a[$2] --> print fields 1 and 2 from new array a that you populated before
# awk -i inplace --> edit file in place with awk (do not overwrite)
# -F '\t'--> field separator of input file is \t
# -v A="$OGSample" -v B="$SAMPLE" --> -v allows you to create variables in awk that you can refer to later
## ^ A is a variable we created earlier in the loop, $OGSample; B is a variable we created in the loop earlier, $SAMPLE

# '{OFS="\t"} --> output field separator is \t
# NR==1{$0=$0 "\t" "SampleID" "\t" "Bin_ID";} --> when on line 1 of the file, print what ever is in parentheses
## $0 means the whole line in the file; $0=$0 and more text separated by quotes are just adding the texts and tabes to line $0

# NR>1{$(NF+1)=A;$(NF+2)=B}1 --> when beyond line one, create an additional column (NF+1) containing A variable, and create another column after that (NF+2) with B variable
## ^ NF --> number of columns in file

# Another Note: because you are using awk -i inplace, you can use NR for specifying the lines -- but if you were looping and creating new files, you would want to use FNR to refresh the line # for every file

# Both of these options below work!
# awk 'BEGIN{FS=OFS="\t"} NR==FNR {a[$2] = $3 FS $4; next} NR==1 {print "Gene_ID", "KO_ID" ,"KO_Function", "Length", "Coverage"} NR > FNR{if($1 in a) {print $1, $2, $3, a[$1]}}' WI_D_9_18_21_A_bin.9_parsed_fC_cov.txt WI_D_9_18_21_A_bin.9_filter_fxns.txt > test2.txt

# awk 'BEGIN {FS=OFS="\t"} NR==FNR {a[$2]=$3 FS $4;next} FNR>1 ($1 in a) {print $1, $2, $3, a[$1] }' WI_D_9_18_21_A_bin.9_parsed_fC_cov.txt WI_D_9_18_21_A_bin.9_filter_fxns.txt > test.txt

# Stack overflow: https://stackoverflow.com/questions/76965831/merging-files-with-awk-by-matching-awk-not-printing-all-array-assignments/76966062#76966062
