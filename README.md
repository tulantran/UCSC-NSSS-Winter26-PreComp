# Winter Classic PreCompetition
This repo is a guide to complete a mini-competition to run and optimize HPL on a Jetstream2 cloud cluster we created, Slugalicious. Your score will be based on your GFLOPs achievement. You can clone this to get the template files included if you want but they're easily copypaste-able. Start early! Only 2 of you can have a job running at a time so you might get stuck in line if you all procrastinate. We will be killing all queued or running jobs Jan 2nd at noon. Post questions in the Discord :p, we might to office hours/check in with you guys. 


I AM SO SAD. IF YOU WANT TO SEE WHAT THIS MESS IS SUPPOSED TO LOOK LIKE CLICK Raw ^

┌────────────────────────────────────────────────────────────────────────────┐
│                          ┌──────────────────────┐ ┌──────────────────────┐ │       This is our mini cluster!  
│     SLUGALICIOUS         │  slimey              │ │  gooey               │ │       Slimey and gooey are the names of our 2 partitions. 
│   ┌──────────────┐       │ ┌────────────────┐   │ │ ┌────────────────┐   │ │       The login node has 32 cores.
│   │              │       │ │ compute-1-of-4 │   │ │ │ compute-3-of-4 │   │ │       Each compute node has 16 cores.
│   │  login node  │       │ └────────────────┘   │ │ └────────────────┘   │ │       All virtualized on AMD 7713 Milan chips. 
│   │              │       │ ┌────────────────┐   │ │ ┌────────────────┐   │ │
│   └──────────────┘       │ │ compute-2-of-4 │   │ │ │ compute-4-of-4 │   │ │
│                          │ └────────────────┘   │ │ └────────────────┘   │ │
│                          └──────────────────────┘ └──────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────┘

# Task Overview
You will need to complete a 2-node HPL run on Slugalicious, on either the partitions (they're identical). Try to tune this to achieve as many floating-point operations per second (FLOPS) as you can. They are all on Ubuntu Linux, using SLURM for job scheduling and connected with ethernet. Each partition consists of 2 nodes each. Since these are virtual, each node only has 16 cores but are running on an AMD Milan 7713. Your only restriction is you may not use Spack to build it. Note that you also don't have sudo permissions so you will pretty much have to build everything from source. Research as you go. The internet is awesome.

You MUST submit the following files:
- either:
  - hplscript.sh - a bash script that we can use to validate your run (good documentation practice)
  - hplreport.txt - description/reflection of what you did and what you tried along the way (still include some commands). Give brief answers to questions in this README.
- HPL.dat - your parameter tunings for your final run. template provided.
- hpl.cmd - the slurm batch script to submit your job. template provided.
- hpl.out - your HPL result output file. 

Please zip these 4 files and call it FirstnameLastname.tar. 
If you give us a script, to validate your run, we will create a new directory with only your HPL.dat, hpl.cmd and script.cmd and run it using 
```
bash script.sh
```
from that same directory. Please make sure that your paths are set accordingly. The last line in your script.sh should be 
```
sbatch hpl.cmd 
```
We will compare the output file to your provided result hpl.out. All steps below with a * must be included in your bash script. For our convenience, please have the outputted hpl result be named validateHPL.out. If there are issues with logging in message @ttttt on discord. 


# Step 1 - ssh onto Slugalicious. Try some commands.

Connect to Slugalicious. Use

```
ssh <yourfirstname(+last initial if andrew)>@149.165.172.82
```
use the password you submitted to us in the google form.

You should see a few things: Jetstream2 updates, announcements, how many users (your teammates!) are logged in to this instance. 

Run this command. What info does it give you? 
```
lscpu
```

Your first SLURM command! What do you see?  
```
sinfo
``` 

Your second. Is anyone running anything right now? Note: on larger systems, specify a user who's current jobs you want to view.
```
squeue
```
Want to see what everyone else is up to, or who's logged in? Try
```
w
```

# Step 2 - Downloading HPL*

To start compiling HPL, you first need its source code. You can find it [here](https://www.netlib.org/benchmark/hpl/). Use
```
wget "https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz"
```
to download it directly to the machine. Once you have the source code, use the `tar` command to untar the the downloaded file. You should end up with a directory called `hpl-2.3`. You then need to get its dependencies.

# Step 3 - Dependencies*
There are 2 main things that High Performance Linpack needs to do solve Ax=b really fast:

- optimized Basic Linear Algebra Subroutines (BLAS)
  - this performs all of the necessary mathematical computations
- optimized Message Passing Interface (MPI)
  - this lets the nodes talk to each other about the problem as they work through it

These libraries may or may not have other dependencies you need to build depending on how you choose them. Here is how you get them:

### Jetstream2 modules

Jetstream2 instances come with many pre-optimized libraries for their machines. I believe these are uniform on all of thier instances even if they are different hardware so not all of the ones available are the best option for our purpose. If you end up using these, research what they are first. 

The `module` command is a feature built into linux and available modules can be set up by admin to have an easy way to set up your environment. It automates setting environment variables and compilers for you. If you're curious about what exactly loading a certain module will do you can hit a:`module show <moduleName>` and it will print essentially the script it runs.

Modules can be explored through these common commands:
- `module avail` gives a list of modules available to load
- `module spider <SearchWord>`searches available modules related to your SearchWord, and tells you commands to load it. (since it may have dependency modules you need to load first)
- `module load <ModuleName>` loads ModuleName into your environment, updates environment variables
- `module unload <ModuleName>`unloads ModuleName from your environment, updates environment variables
- `module purge <ModuleName>`this will clear all modules from your current environment
- `module list` shows modules you currently have loaded

There are a few other commands that can use modules' description to help you but Jetstream2 doesn't provide any descriptions so I will not be showing those here. Those may be useful on Hummingbird if you ever play with it.

### Build from source
This is a bit more complicated then just loading modules but gets to the root of what we spend most of our time doing in HPC. You can choose from any available libraries for these dependencies. 

##### Common MPI libraries:
- OpenMPI
- Intel MPI
- MPICH
- HPC-X
  
##### Common BLAS Libraries:
- OpenBLAS
- Intel MKL
- AOCL
- BLIS

"Open" things obviously work on anything. Good ol' reliable. Could be cool to try configuring some other stuff too though. Do some research. How are you picking your libraries? Things to consider AMD 7713, ethernet, 32 cores total, 2 nodes, maybe virtual cluster?

You will need to wget and untar or clone a directory to get these libraries. Explore whats in them first. Try not get overwhelmed. 

# Step 4 - Configure and make*
Once you've figured out your dependencies, you need to compile HPL itself. But first, we need to talk about how these dependencies are managed.

## Linking is fun
HPL depends on BLAS and MPI. You could try compiling HPL by running the `configure` script. That will make a `Makefile` you can use to then run `make`, and that should succesfully compile HPL. But that isn't a super precise way to do it. It's hard to know which versions of the dependencies the `configure` script found. And on top of that, it's hard to be certain the libraries that are present on the login node are also present on the compute nodes. If using the `configure` script works for you, and you managed to get a succesful HPL run with it, great! Use that, as it saves you some headaches. But, if it doesn't, we'll have to get our hands a little dirty. We're going to have to manually edit a template Makefile and tell the compiler which libraries we want to use.

## Telling the compiler how you want it done
Copy the template Makefile `Make.Slugalicious` to inside of the `hpl-2.3` directory. 
### MPI
You first need to tell it where your MPI lives, so go find the MPI section. It should look something like
```
MPdir        =
MPinc        =
MPlib        =
```
When you used `make install` after compiling your MPI, it should have installed your MPI library to the directory you gave it. Set `MPdir` to that directory. Now, the next flag, `MPinc`, is asking for the "include" directory, where all of the header files necessary for compilation live. There should be a folder called `include` inside of the `MPdir` directory that has exactly that. So, set `MPinc` to that, `$(MPdir)/include`. Then, you need to tell the compiler where the library object files are, which is what actually gets executed during runtime, versus the include files necessary for compilation. That lives in the same `MPdir` folder within a `lib` folder, and inside that folder, there should be a file called `libmpi.a`. If not, look inside that folder with `ls` and see what's there and what's missing! If you used a module, leave this blank.
### BLAS
Now you need to tell the compiler where your BLAS comes from. Thankfully, it's pretty similar. Look for the LA variables, they should look like this:
```
LAdir        =
LAinc        =
LAlib        =
```
If you're using the BLAS library from the installed `libopenblas-dev` package, you can just leave LAdir and LAinc blank and fill in LAlib with `\usr\include\x86_64-linux-gnu\libopenblas.a`. This is the direct path to the openblas library. If you compiled BLAS yourself however, you fill out the three basically the same way as you did with MPI. `LAdir` points to the main directory, `LAinc` points to the `include` directory within `LAdir`, and then `LAlib` is the `libopenblas.a` file within the `lib` directory.

### Compiler & Compiler Flags
Now you need to tell the Makefile where to find your compiler. For this project, you're going to use the `mpicc` compiler from OpenMPI. That should be in the `bin` folder within the main OpenMPI folder, wherever you decided to store that after running `make install`. Find
```
CC       = 
```
and set it to be the path to your `mpicc` compiler. Then, mess with `CCFLAGS`. Right now, it has a few already. But there are more you should put. Think about optimization flags with the `-O1` syntax, which is the highest one you can use? On top of that, use `-march=` and `-mtune=` flags. This tells the compiler to optimize for a specific chip. These systems use AMD Epyc Milan 7713 chips, which use Zen 3 microarchitecture (`znver3`). 

## Compiling!
Now that you have written your Makefile, it's smooth sailing from here. Use `make -arch=Slugalicious -j 32` to compile for the Slugalicious architecture (specifies the Makefile you were just editing) and with 32 jobs in parallel (the login node has 32 cores, best to take advantage of that). If all goes well, there should be no errors thrown, and the executable should be placed in `bin/Slugalicious`!


# Step 5 - Create your HPL.dat
This repo includes a template. I've put X's where we will recommend how you set these in this section. These parameters will have the greatest effect on your run. You are welcome and encouraged to play with the other ones, where you may be able to squeeze out some extra flops. [This](https://www.netlib.org/benchmark/hpl/tuning.html) will tell you what each does and how . When you submit the job using sbatch, make sure your HPL.dat is in the same directory, or specify the directory in your SLURM batch script.

### Ns

This will be the dimension of your square matrix $A$ in $Ax=b$. We want to pretty much max out the size based on how much memory we have. Given that a double precision float is 8 bytes, to get the max dimension of our matrix we divide how many bytes we have by 8 and then take the square root. Hint: Each node has 60GB RAM

N = sqrt((RAM in bytes)/(8 bytes))

BUT this N alone would take up our entire RAM and we need some of that for other stuff like the OS. So scale it down a bit but not too much. %85 of that is a conservative start. Push it until it tanks your performance. It can help to have this be a multiple of your NB. Where did it start to tank?

### NB

Your block size. Your matrix will get partitioned into smaller squares NB X NB. Keep to multiples of 64. Smaller if compute-bound. Larger if communication-bound. Look into why if you feel. Start in 192-384 range. What worked the best? Why?

### P and Q

Your P x Q should multiply to your number of MPI tasks (which you set in your slurm batch script). It determines how your matrix is chopped up and divided. Your Q should be less than than P. In a perfect set up, the most square P and Q would perform best. Experiment with slightly rectangular ones. Why might those work better in some cases? Why Q less than P?

# Step 6 - Create your SLURM batch script

This repo includes a template. Look at it now. It's pretty easy to follow. A decent run is well under an hour, maybe give yourself 2. Make sure to set a time limit to prevent jobs from hanging. 

The one nuanced concept here is what a "task" is. This is an MPI thing. When you have MPI in your code, and you specify for example 4 tasks a.k.a MPI Ranks, your program will run 4 times BUT each process will respond differently and do different parts of the code based on its MPI Rank or ID. These processes will communicate with eachother via MPI which is slower than lower level communications obviously. Historically, programs were written with a one rank per core assumption. That's likely to be inefficient on modern machines. You want a few threads per rank. Make sure (#tasks)*(cpuspertask)=total cores obviously.

# Step 7 - Submit your Job* 
```
sbatch hpl.cmd
```
and thats the last that you should put in your bash script if you choose that option!

To check the status of your job:
```
squeue -u $USER
```
If there is nothing there, your job has completed and you should look for the output files you named in your hpl.cmd script.

If you decide you want to cancel the job. (either kill it or remove from queue), check the ID with squeue and then 
```
scancel <jobID>
```

# Step 8 - Compare to the theoretical max and decide if you are satisfied :)

The theoretical max of 32-core run on AMD Milan 7713 is 1.024 TFLOPS. Try to get as close to this as you can.

If you are below 75% of this, there are simple things you can do that will make a huge difference.

Justification: 
- 





