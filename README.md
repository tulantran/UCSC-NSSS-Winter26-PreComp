# How we set this competition up

## Selecting nodes
First, we needed to select the number of nodes and how many cores they'd have. We were limited to 124 total cores and 5 total instances. We wanted to have multiple SLURM partitions so we decided on having 1 32-core login node and 4 16-core compute nodes split into 2 partitions. 

## Setting up accounts on login node
We wanted the competition to all have separate home directories for each participant so to acheive that we needed to make an account for everyone. We just made an account for each person using their first name, all lowercase. And then we used a google form to collect what password everyone wanted and we used. 
```
sudo adduser --disable-password <user>
```
```
sudo password <user>
```
to set the password for each person.

We sync the users to the rest of the nodes after slurm is set up for exouser.

## Setting up the manila share
Jetstream doesn't let you easily set up a manila share from the exosphere interface, you have to use the horizon interface. [This](https://docs.jetstream-cloud.org/ui/horizon/manila/) guide is perfect for setting it up. Use [this](https://docs.jetstream-cloud.org/ui/horizon/login/) guide to log on to Horizon.

### Home sharing

This manila share was mounted at /home/. This lets things like ssh keys synchronize very easily over the compute and login nodes. This was pretty handy when syncing all of the ssh keys so things like MPI and HPL which use ssh could work. Instead of having to manually copy a bunch of ssh keys, the manila share handled things quite nicely. 

We created a 500gb share and mounted it using our `mount-home-manila-share.` We sshed into each individual node

### Problems..
Nothing works perfectly the first try. When trying to login to a compute node from the login node when logged in as a user, I encountered issues with the permissions for .ssh being set incorrectly. This wouldn't let the user write its own keys or read them either. The `.ssh` directory needed to have `700` permissions and the keys need `600` permissions. So, I had to set the permissions correctly. Once that was done, I realized I had to also generate keys for all of the users so they were all present in their directories (and with correct perms set). The script `ssh-gen-fix-perms.sh` goes over this.

#### Weird error
When fixing the SSH perms, I tried to run the script like

```
sudo ssh-gen-fix-perms.sh
```
That didn't work, and I got errors about `[[` not being found. It turns out when you use `sudo` to run a script, instead of using bash to interpret the script, it instead defaults to `Dash` to interpret the scripts which doesn't understand `[[`. So, you need to run the script like

```
sudo bash ssh-gen-fix-perms.sh
```
To get it to run.


## Setting up slurm
For this, we decided to use most of the slurm script we made during the IndySCC competition. A lot of this was made by our fellow teammate Caleb Lin. We had to edit it to fit our needs. He also pulled some help from [Slurm for Dummies](https://github.com/SergioMEV/slurm-for-dummies).

### Some simple verification
Upon running `srun --nodes=2 id` when logged in as `exouser` (the admin), this output was produced:
```
uid=1001(exouser) gid=1001(exouser) groups=1001(exouser),27(sudo),110(admin),127(docker),1000(ubuntu)

uid=1001(exouser) gid=1001(exouser) groups=1001(exouser),27(sudo),110(admin),127(docker),1000(ubuntu) 
```

### Bleh... partitions
Right now if you try to target the whole 4 node system, slurm will complain since there is no one partition that covers all 4 nodes. We could make an overlapping partition that covers all 4 nodes, and we probably should. Right now we have slimey and gooey for 2 nodes each. Not sure if trying to target `slimey,gooey` works either right now.
