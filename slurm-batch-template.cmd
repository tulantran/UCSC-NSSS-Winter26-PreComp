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


export HPL_DIR="/path/to/hpl"
export BLAS_DIR="/path/to/blas"
export MPI_DIR="/path/to/mpi"
#you can experiment with these:
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1

#probably put these for proper communication, feel free to look into why for js2
export OMPI_MCA_btl_tcp_if_include=enp1s0 
export OMPI_MCA_btl=self,vader,tcp 


mpirun -np <numprocs> xhpl
