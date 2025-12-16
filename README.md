# Winter Classic PreCompetition
This repo is a guide to complete a mini-competition to run and optimize HPL on a Jetstream2 cloud cluster we created, Slugalicious. Your score will be based on your GFLOPs achievement. You can clone this to get the 2 template files included if you want.

# Task Overview
You will need to complete a 2-node HPL run on Slugalicious26, on any of the partitions (they're all identical). Try to tune this to achieve as many floating-point operations per second (FLOPS) as you can. They are all on Ubuntu Linux, using SLURM for job scheduling and connected with ethernet. Each partition consists of 2 nodes each. Since these are virtual, each node only has 16 cores but are running on an AMD Milan 7713. Your only restriction is you may not use Spack to build it. Note that you also don't have sudo permissions so you will have to build everything from source or we will have a few unoptimized installations for you if you want a cop-out.

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

Connect to Slugalicious. Use

```
ssh <<IP TBD>>
```
and enter <<PW TBD>>


# Step 2 - HPL*

To start compiling HPL, you first need its source code. You can find it [here](https://www.netlib.org/benchmark/hpl/). Use
```
wget "https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz"
```
to download it directly to the machine. Once you have the source code, use the `tar` command to untar the the downloaded file. You should end up with a directory called `hpl-2.3`. You then need to get its dependencies.

# Step 3 - Dependencies*

# Step 4 - Configure and make*

# Step 5 - Create your HPL.dat
This repo includes a template.

# Step 6 - Create your SLURM batch script
This repo includes a template.

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

The theoretical max of 32-core run on AMD Milan 7713 is 1.024 TFLOPS. Try to get as close to this as you can.

If you are below 75% of this, there are simple things you can do that will make a huge difference.

Justification: 
- 





