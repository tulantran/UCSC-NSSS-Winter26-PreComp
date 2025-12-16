# Winter Classic PreCompetition
This repo is a guide to complete a mini-competition to run and optimize HPL on UCSC's cluster, Hummingbird. Your score will be based on your GFLOPs achievement. You can clone this to get the 2 template files included if you want.

# Task Overview
You will need to complete a 2-node HPL run on Hummingbird, on the "instruction" partition. Try to tune this to achieve as many floating-point operations per second (FLOPS) as you can. Hummingbird runs Fedora OS, uses SLURM for job scheduling and connected with 10Gbps shared ethernet. The instruction partition consists of 2 nodes each with a single  as "nodes," within the partition. Each node has 48 cores and 192GB, for a total of 96 cores and 384GB on the partition. Your only restriction is you may not use Spack to build it. Note that you also don't have sudo permissions so you will have to build everything from source or use pre-installed modules. 

You MUST submit the following files:
- script.sh - a bash script that we can use to validate your run (also good documentation practice)
- HPL.dat - your parameter tunings for your final run
- hpl.cmd - the slurm batch script to submit your job
- hpl.out - your HPL result 

Please zip these 4 files and call it FirstnameLastname.tar. 
To validate your run, we will create a new directory with only your HPL.dat, hpl.cmd and script.cmd and run it using 
```
bash script.sh
```
from that same directory. Please make sure that your paths are set accordingly. The last line in your script.sh should be 
```
sbatch hpl.cmd 
```
We will compare the output file to your provided result hpl.out. All steps below with a * must be included in your bash script. For our convenience, please have the outputted hpl result be named validateHPL.out. If there are issues with this message @ttttt on discord. 


# Step 1 - ssh onto Hummingbird

Connect to Hummingbird. Use

```
ssh cruzid@hb.ucsc.edu
```
and login with your cruzid password to login to Hummingbird. Now, you should be logged in to Hummingbird!

If you get port 22 connection issue, you must use the school's VPN. Instructions [here](https://its.ucsc.edu/services/network-and-infrastructure/network-and-connectivity-management/campus-virtual-private-network-vpn/).

# Step 2 - HPL*

To start compiling HPL, you first need its source code. You can find it [here](https://www.netlib.org/benchmark/hpl/). Use
```
wget "https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz"
```
to download it directly to the machine. Once you have the source code, use the `tar` command to untar the the downloaded file. You should end up with a directory called `hpl-2.3`. You then need to get its dependencies.

# Step 3 - Dependencies*

Hummingbird comes with many pre-optimized modules. You may either search through them and find out which ones are best for your run or build dependencies from source.

Here is a list of useful commands for modules:
```
module avail
```
gives a list of modules available to load

```
module spider <SearchWord>
```
searches available modules related to your SearchWord, and tells you commands to load it. (since it may have dependency modules you need to load first)

```
module load <ModuleName>
```
loads ModuleName into your environment, updates environment variables

```
module unload <ModuleName>
```
unloads ModuleName from your environment, updates environment variables

```
module list
```
shows modules you currently have loaded

# Step 4 - Configure and make*

# Step 5 - Create your HPL.dat
This repo includes a template.

# Step 6 - Create your SLURM batch script
This repo includes a template.
For more general instructions on how to create these [here](https://hummingbird.ucsc.edu/documentation/creating-scripts-to-run-jobs/).
There are also a bunch of example templates in /hb/software/scripts! The most useful to you will probably be "slurm-mpi-job-example.slurm"

# Step 7 - Submit your Job* 
```
sbatch hpl.cmd
```
and thats the last that you should put in your bash script!

To check the status of your job:
```
squeue -u $USER
```
If there is nothing there, your job has completed and you should look for the output files you named in your hpl.cmd script.

# Step 8 - Compare to the theoretical max and decide if you are satisfied :)

Here's some info you need to calculate the theoretical max:




