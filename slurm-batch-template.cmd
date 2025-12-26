#!/bin/bash
#SBATCH -p <partition name>
#SBATCH -J <job name that will be visible to all in queue>
#SBATCH -e <error output filename, put this in your shared folder>
#SBATCH -o <std output filename, put this in your shared folder>
#SBATCH -N <number of nodes (2)> 
#SBATCH --ntasks=< # total tasks> #(start with 1task per core) change it later if you know what youre doing (and the two lines below)
#SBATCH --ntasks-per-node=< # tasks per node>
#SBATCH --cpus-per-task= < # cpu cores per tasks>
#SBATCH -t <maximum time in hh:mm:ss>
#SBATCH --chdir=/example/path # use to set where the working directory is when the job is ran.

module load <module name> #if any; delete if you built all from source

#may have to change the variable name to match your library choice, these are set to 1 assuming you have 1 task per core
#if you know what you're doing these are threads per task
export OPENBLAS_NUM_THREADS=1 #works for openblas
export OMP_NUM_THREADS=1 #works for openmpi

# dont change these. network stuff.
export OMPI_MCA_btl_tcp_if_include=enp1s0 
export OMPI_MCA_btl=self,vader,tcp 


mpirun -np <numprocs/tasks> <executable>
