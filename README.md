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

## Setting up the manila share
Jetstream doesn't let you easily set up a manila share from the exosphere interface, you have to use the horizon interface. [This](https://docs.jetstream-cloud.org/ui/horizon/manila/) guide is perfect for setting it up. Use [this](https://docs.jetstream-cloud.org/ui/horizon/login/) guide to log on to Horizon.


## Setting up slurm
For this, we decided to use most of the slurm script we made during the IndySCC competition. A lot of this was made by our fellow teammate Caleb Lin. We had to edit it to fit our needs. He also pulled some help from [Slurm for Dummies](https://github.com/SergioMEV/slurm-for-dummies).