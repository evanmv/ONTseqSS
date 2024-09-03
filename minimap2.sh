#!/bin/sh
#SBATCH --job-name=minimap2
#SBATCH --account=ec12
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=2:00:00
#SBATCH --mem=16G

#setup
set -o errexit
set -o nounset

module --quiet purge

module load minimap2/2.22-GCCcore-11.2.0

#Argument
ref=$1
fq=$2

#Run minimap2
minimap2 -ax map-ont -t 4 $SUBMITDIR/$ref $SUBMITDIR/$fq > alignment.sam

#Finish message
echo "Done"
