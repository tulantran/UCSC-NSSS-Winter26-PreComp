#!/bin/bash
#SBATCH -p <partition name>
#SBATCH -J <job name that will be visible to all in queue>
#SBATCH -e <error output filename, put this in your shared folder>
#SBATCH -o <std output filename, put this in your shared folder>
#SBATCH -N <number of nodes (2)> 
#SBATCH --ntasks=< # total tasks (recommended 1 per total cores)>
#SBATCH --ntasks-per-node=< # tasks per node>
#SBATCH --cpus-per-task= < # cpu cores per tasks>
#SBATCH -t <maximum time in hh:mm:ss>
#SBATCH --chdir=/example/path # use to set where the working directory is when the job is ran.

module load <module name> #if any; delete if you built all from source

# this is a bit redundant if you manually specificied in your make file, could be nice for if you used config
export HPL_DIR="path/to/your/hpl/x" 
export BLAS_DIR="path/to/your/blas/x"
export MPI_DIR="path/to/your/mpi/x"

# dont change these. they are kinda niche dw abt it too much some thread safety and network stuff.
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export OMPI_MCA_btl_tcp_if_include=enp1s0 
export OMPI_MCA_btl=self,vader,tcp 


mpirun -np <numprocs> <executable>
