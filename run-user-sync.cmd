#!/bin/bash
#SBATCH -J userIDsync
#SBATCH -e /mnt/shared/sync%j.err
#SBATCH -o /mnt/shared/sync%j.out

#SBATCH hetjob
#SBATCH -p <partition1>
#SBATCH -N 2
#SBATCH --ntasks-per-node=2
#SBATCH -t 00:05:00

#SBATCH hetjob
#SBATCH -p <partition2>
#SBATCH -N 2
#SBATCH --ntasks-per-node=2
#SBATCH -t 00:05:00
