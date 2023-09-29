#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --cpus-per-task=8 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=400G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --mem=600G # < if you are threading, ask for whole memory and not memory per CPU
#SBATCH --time=1-00:00:00  # 14 days, 0 hrs
#SBATCH --output=Filter_KOFamScan_Annotations_8.22.23.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Filter_KOFamScan_Annotations_8.22.23"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

module load python

# Make directory to store results
if [[ ! -d ./Filtered_KOFamScan_Results ]]; then
    mkdir ./Filtered_KOFamScan_Results
fi

# input into KoFam_Scan will be .faa files from Prokka or Prodigal (FASTA file of translated CDSs found in the contigs into Protein sequences)

# Parse through functions with Python script written by Mike Lee
for FILE in *_functions_kfs.txt;
do
    f=$(basename $FILE)
    SAMPLE=${f%_functions*}
    
    if [[ ! -f ${SAMPLE}_filter_fxns.tsv ]]; then
        python 12b.1_Filter_KoFamScan_Results.py -i ${SAMPLE}_functions_kfs.txt -o ${SAMPLE}_filter_fxns.txt
        
        cp ${SAMPLE}_filter_fxns.txt ./Filtered_KOFamScan_Results
    fi
    
    
    if [[ ! -f ${SAMPLE}_filter_fxns_mapper.txt ]]; then
        awk -F '\t' '{OFS = FS} NR>=2 {print $1,$2}' ${SAMPLE}_filter_fxns.txt > ${SAMPLE}_filter_fxns_mapper.txt
        cp ${SAMPLE}_filter_fxns_mapper.txt ./Filtered_KOFamScan_Results
    fi
    
done



# Mike's script usage:
#    python 12b.1_Filter_KoFamScan_Results.py -i 5492-KO-tab.tmp -o 5492-annotations.tsv
#    -i --> input file
#    -o --> output file
# More here: https://github.com/AstrobioMike/bit/blob/master/bit/bit-filter-KOFamScan-results

# awk -F '\t' -- read file in w/ tab delimiter
# '{OFS = FS} -- output field separator = input field separator, here that's a tab (so input AND output are tab delimited)
# NR>=2 {print $1,$2}' -- NR stands for total lines read by the script; for lines ==2 and >2, print only field 1 ($1) and field 2 ($2)

