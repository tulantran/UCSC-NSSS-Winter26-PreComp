# Winter Classic PreCompetition
This repo is a guide to complete a mini-competition to run and optimize HPL on UCSC's cluster, Hummingbird. Your score will be based on your GFLOPs.

# Task
You will need to complete a 2-node HPL run on Hummingbird, on the "instruction" partition. Try to tune this to get as many floating-point operations per second (FLOPS). The instruction partition consists of 2 AMD 6000 chips. We also refer to these chips as "nodes," within the partition. They each have 48 cores and 192GB, for a total of 96 cores and 384GB on the partition. Your only restriction is you may not use Spack to build it. 

You MUST submit the following files:
- script.sh - a bash script that we can run to validate your run
- HPL.dat - your parameter tunings for your final run
- hpl.cmd - the slurm batch script to submit your job
- hpl.out - your HPL result 

Please zip these 4 files and call it <FirstnameLastname>hbHPL.tar.
To valid your run, we will create a new directory with only your HPL.dat, hpl.cmd and script.cmd and run it using 
```bash script.sh
```
from that same directory. 
We will compare the output file to your provided result hpl.out


# Step 1

This guide serves to get you started on compiling HPL on UCSC's own supercomputing cluster, Hummingbird. Firstly, you need to connect to Hummingbird. Use

```
ssh cruzid@hb.ucsc.edu
```
and login with your cruzid password to login to Hummingbird. Now, you should be logged in to Hummingbird!



To start compiling HPL, you first need its source code. You can find it [here](https://www.netlib.org/benchmark/hpl/). Use
```
wget "https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz"
```
to download it directly to the machine. Once you have the source code, use the `tar` command to untar the the downloaded file. You should end up with a directory called `hpl-2.3`. You then need to get its dependencies.
