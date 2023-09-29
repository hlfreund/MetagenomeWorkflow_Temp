#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --cpus-per-task=1 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=400G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --mem=400G # < if you are threading, ask for whole memory and not memory per CPU
##SBATCH --time=20:00:00     # 20 hrs
#SBATCH --output=Rename_Contigs_10.10.22.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="RenameContigs_10.10.22"
#SBATCH -p aronsonlab

for i in *_contigs.fasta;
do
    awk -i inplace '/^>/{print ">c_" ++i; next}{print}' ${i}
done

awk -F "\t" '/^/{print "c_" ++i; next}{print}' ${i}

    awk '/^>/{print ">c_" ++i; next}{print}' final.contigs.fa > SSD_Contigs_CleanName.fa

for i in *_gene_fxns_coverage.txt;
do
    f=$(basename $i)
    SAMPLE=${f%_gene*}
    new=${SAMPLE//\_/\.}

    #awk -i inplace '(gsub(/^c/, new"_c")) {print} new="${$SAMPLE//\_/\.}"' ${i}
    awk -v A="$new" 'BEGIN {OFS="\t"} (gsub(/^c/, A)) {print} ' ${i} > ${SAMPLE}_gene_fxns_cov_clean.txt

done

for i in *_parsed_fxns.tsv;
do
    f=$(basename $i)
    SAMPLE=${f%_parsed*}
    new=${SAMPLE//\_/\.}

    #awk -i inplace '(gsub(/^c/, new"_c")) {print} new="${$SAMPLE//\_/\.}"' ${i}
    
    ## if you want to keep the header, please do this next line when renaming contigs
    awk -v A="$new" 'FNR==1 && NR!=1 { while (/^<header>/) getline; } 1 (gsub(/^c/, A)) {print} ' ${i} > ${SAMPLE}_parsed_fxns_clean.tsv

done

for i in *_parsed_fxns_samples.txt;
do
    f=$(basename $i)
    SAMPLE=${f%_parsed*}
    new=${SAMPLE//\_/\.}

    #awk -i inplace '(gsub(/^c/, new"_c")) {print} new="${$SAMPLE//\_/\.}"' ${i}
    awk -v A="$new" '(gsub(/^c/, A)) {print} ' ${i} > ${SAMPLE}_parsed_fxns_samp_clean.txt

done

for i in *_gene_fxns_cov_clean.txt;
do
    f=$(basename $i)
    SAMPLE=${f%_gene*}
    new=${SAMPLE//\_/\.}

    #awk -i inplace '(gsub(/^c/, new"_c")) {print} new="${$SAMPLE//\_/\.}"' ${i}
    awk -v A="$new" '(gsub(/^c/, A)) {print} ' ${i} > ${SAMPLE}_gene_fxns_cov_updated.txt

done


