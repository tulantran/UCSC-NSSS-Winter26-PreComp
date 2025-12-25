#!/bin/bash
#SBATCH -p <partition name>
#SBATCH -J <job name that will be visible to all in queue>
#SBATCH -e <error output filename, put this in your shared folder>
#SBATCH -o <std output filename, put this in your shared folder>
#SBATCH -N <number of nodes (2)> 
#SBATCH --ntasks=< # total tasks (recommended 1 per total cores)>
#SBATCH --ntasks-per-node=< # tasks per node>
#SBATCH --cpus-per-task=< # cpu cores per tasks>
#SBATCH --mem=< total ram in GB >G
#SBATCH -t <maximum time in hh:mm:ss>
#SBATCH --chdir=/example/path # use to set where the working directory is when the job is ran.

module load <module name> #if any; delete if you built all from source

export HPL_DIR="path/to/your/hpl/x"
export BLAS_DIR="path/to/your/blas/x"
export MPI_DIR="path/to/your/mpi/x"

mpirun -np <numprocs> <executable>
