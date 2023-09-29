#!/bin/bash -l

# NOTE: I run these scripts using an interactive job so that I can immediately check the output and rerun the code in the terminal again if I need to make changes, rather than submitting these scripts as jobs.
# To run an interactive job:
## srun -p node_name_here --mem=400gb --time=1-00:00:00 --pty bash -l
## ^ replace node_name_here with a node (e.g. aronsonlab or highmem); --mem is total mem needed; --pty tells HPC to open a pseudo terminal to run the interactive job in; bash -l species that we will be using the Bash (shell) language

# Make directory to store parsed KOFamScan results
if [[ ! -d ./Parsed_KOFamScan_Results ]]; then
    mkdir ./Parsed_KOFamScan_Results
fi

# convert tsv into text file & update contig names
for FILE in *_fC_gene_coverage.tsv;
do
    f=$(basename $FILE)
    SAMPLE=${f%_fC*}
    
    if [[ ! -f ${SAMPLE}_parsed_fC_cov.txt ]]; then
        # skip first line, then rename GeneID after skipping header on line 2; print only columns we want into new file
        # for single assembly: gene ID renamed from 1_1 to c_1_1 to match KOFamScan geneID -->  will be used for merging later
        # for coassembly: Chr ID renamed from c_x to c_x_1, where x is the Chr #, and _1 is the gene number on each contig
        awk -F '\t' -v OFS='\t' 'NR>1 {split($1,a,"_"); $2=$2 "_" a[2]} {print $1,$2,$6,$7}' ${SAMPLE}_fC_gene_coverage.tsv > ${SAMPLE}_parsed_fC_cov.txt
    fi
done

# -F '\t'--> input file separator is tab
# -v --> allows us to create variables within awk
# OFS='\t' --> output field separator is tab
# NR>1 --> if total lines read (not just FR which is file line read) is greater than 1, do x
# {split($1,a,"_"); --> slit field 1 ($1) into array "a", using _ as the field separator
# $2 = $2 "_" a[2]} --> field 2 ($2) is now equal to $2_ and then a[2], which is the second part of what was $1 now stored in array a as second field (a[2])
## ^^ will only perform this after $1 has been split into array a, with each "piece" of $1 as the fields in array a
# {print $1,$2,$6,$7}' --> print fields 1, 2, 6, 7

# add column with original sample ID & bin ID (if looking at bin coverage file)
for i in *_parsed_fC_cov.txt;
do
    f=$(basename $i)
    SAMPLE=${f%_parsed*}
    OGSample=${SAMPLE%_bin*}
    # new=${SAMPLE//\_/\.}
    
    if [[ ${SAMPLE} == *"bin."* ]]; then
        awk -F '\t' -v A="$SAMPLE" -v B="$OGSample" '{OFS="\t"} NR==1{print $0 "\t" "SampleID" "\t" "BinID";} NR>1{print $0, B, A} ' ${i} > ${SAMPLE}_parsed_fC_cov_samples.txt
        # -v --> create defined variables in awk script
        # NR==1 means first line read by script
        # NR>1 means lines beyond the first line read by awk (out of total lines read)
        # $0 indicates all contents in the line (not by field)
        # B and A represent variables that we had defined before awk script and are calling in during awk script
    else
        awk -F '\t' -v A="$SAMPLE" '{OFS="\t"} NR==1{print $0 "\t" "SampleID";} NR>1{print $0, A} ' ${i} > ${SAMPLE}_parsed_fC_cov_samples.txt
        
    fi

    # awk -i inplace '(gsub(/^c/, new"_c")) {print} new="${$SAMPLE//\_/\.}"' ${i}
    # awk -v A="$SAMPLE" '{OFS="\t"} NR==1{$0=$0 "\tSampleID";} NR>1{$(NF+1)=A;}1 ' ${i} > ${SAMPLE}_parsed_fC_cov_samples.txt

done



##############################################################################
# if only adding a bin or sample ID, and not multiple IDs to columns...
for i in *_parsed_fC_cov.txt;
do
    f=$(basename $i)
    SAMPLE=${f%_parsed*}
    #new=${SAMPLE//\_/\.}

    #awk -i inplace '(gsub(/^c/, new"_c")) {print} new="${$SAMPLE//\_/\.}"' ${i}
    awk -v A="$SAMPLE" '{OFS="\t"} {if (NR!=1) {print $0, A}}' ${i} > ${SAMPLE}_parsed_fC_cov_samples3.txt


done
