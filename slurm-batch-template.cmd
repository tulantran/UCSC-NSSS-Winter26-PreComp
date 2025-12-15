#!/bin/bash
#SBATCH -p <partition name (instruction)>
#SBATCH -J <job name that will be visible to all in queue>
#SBATCH -e <error output filename>
#SBATCH -o <std output filename>
#SBATCH -N <number of nodes (2)> 
#SBATCH --ntasks=< # total tasks (recommended 1 per total cores)>
#SBATCH --ntasks-per-node=< # tasks per node>
#SBATCH --cpus-per-task=< # cpu cores per tasks>
#SBATCH --mem=< total ram in GB >G
#SBATCH -t <maximum time in hh:mm:ss>

module load <ur modules maybe put a few lines of this one>
