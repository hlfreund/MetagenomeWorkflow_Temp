#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --cpus-per-task=1 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=10G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --mem=10G # < if you are threading, ask for whole memory and not memory per CPU
#SBATCH --time=1-00:00:00     # 1 day
#SBATCH --output=FastQC_PostTrim_QualCheck.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="FastQC_PostTrim_QualCheck"
#SBATCH -p batch

module load fastqc/0.11.9

if [[ ! -d ./Trim_FastQC_Results ]]; then
    mkdir Trim_FastQC_Results
fi

for FILE in Trimmed_Seqs/*.fastq;
do
    f=$(basename $FILE)
    SAMPLE=${f%_R*}

    fastqc $FILE -o Trim_FastQC_Results
    
done
