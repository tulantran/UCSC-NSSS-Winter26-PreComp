# Slugalicious Cluster Setup

This repo holds the bash scripts used to set up our specific cluster 
configuration for the Winter Classic pre-competition. We did not follow 
an exact tutorial — we wanted to experiment and figure it out ourselves, 
so there was a lot of trial and error.

## Architecture
┌─────────────────────────────────────────────────────────────────┐
│                      SLUGALICIOUS                               │
│                                                                 │
│   ┌──────────────┐    ┌─────────────────┐  ┌─────────────────┐ │
│   │  login node  │    │     slimey      │  │      gooey      │ │
│   │   32 cores   │    │ compute-1-of-4  │  │ compute-3-of-4  │ │
│   │  AMD 7713    │    │ compute-2-of-4  │  │ compute-4-of-4  │ │
│   └──────────────┘    │  16 cores each  │  │  16 cores each  │ │
│                       └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

- 5 total instances, 124 total cores (Jetstream2 limit)
- All nodes: AMD EPYC 7713, 60GB RAM
- Networking: Ethernet (internal Jetstream2 network)
- Job scheduler: SLURM
- Authentication: Munge
- Shared filesystem: OpenStack Manila (CephFS-backed, mounted at /home)

## Script run order

Each layer depends on the previous. Run in this order:

1. `slurm-set-up.sh` — installs Munge + SLURM, distributes config to all nodes
2. `mount-home-manila-share` — mounts shared /home via Manila/CephFS on each node
3. `__user-id-sync.sh__` — syncs UIDs/GIDs from login node to compute nodes
4. `set-mounted-home-permissions` — creates per-user directories and sets ownership
5. `ssh-gen-fix-perms.sh` — generates SSH keys and authorizes users cluster-wide
6. `key-sync.sh` — final key sync pass

## Selecting nodes

We were limited to 124 total cores and 5 total instances on Jetstream2. 
We wanted multiple SLURM partitions so we settled on 1 login node (32 cores) 
and 4 compute nodes (16 cores each) split into 2 partitions: slimey and gooey.

## Setting up accounts on the login node

We wanted each competition participant to have a separate home directory,
so we made an account for each person using their first name, all lowercase.
We used a Google Form to collect passwords and then ran:

```bash
sudo adduser --disable-password <user>
sudo passwd <user>
```

Users get synced to the rest of the nodes after SLURM is set up for exouser
using `__user-id-sync.sh__`.

## Setting up the Manila share

Jetstream2 doesn't let you easily set up a Manila share from the Exosphere 
interface — you have to use the Horizon interface. __This__ guide is perfect 
for setting it up. Use __this__ guide to log in to Horizon.

Manila is OpenStack's shared filesystem service. On Jetstream2 it uses CephFS 
as the backend. To mount it you need the Ceph monitor IPs and an access key, 
both available from the Manila share details in the OpenStack dashboard.

We created a 500GB share and mounted it using `mount-home-manila-share`. 
We SSH'd into each node individually and ran the script. This could be 
automated with a similar sshpass setup as used in `slurm-set-up.sh` in the future.

## Home sharing

The Manila share is mounted at `/home`. Because it's a shared CephFS filesystem, 
any file written on one node is immediately visible on all others — no syncing needed.

This made SSH key setup much cleaner: keys only need to be generated once on the 
login node. Since `~/.ssh` lives on the shared mount, the keys are instantly 
present on every compute node. MPI and HPL both use SSH for process launch, 
so this saved us from having to manually copy keys everywhere.

It also means UIDs must be consistent across all nodes. CephFS stores files by 
UID — if a user is UID 1001 on the login node but 1002 on a compute node, their 
files appear owned by the wrong user. `__user-id-sync.sh__` handles this by using 
`srun --ntasks-per-node=1` to create users via the scheduler itself, which runs 
exactly once per node per partition without needing to hardcode IPs or manage 
SSH credentials separately.

## SSH permission issues

When trying to log in to a compute node from the login node as a regular user, 
we ran into permission errors on `.ssh`. The `.ssh` directory needs `700` 
permissions and the keys need `600` — SSH silently refuses to use keys with 
looser permissions. We also needed to generate keys for all users so they were 
present in their directories. `ssh-gen-fix-perms.sh` handles both.

## Weird sudo/dash error

When running the fix perms script we tried:

```bash
sudo ssh-gen-fix-perms.sh
```

This gave errors about `[[` not being found. When you run a script with `sudo` 
directly, it defaults to `dash` as the interpreter instead of `bash`, and `dash` 
doesn't understand `[[`. Run it as:

```bash
sudo bash ssh-gen-fix-perms.sh
```

## Setting up SLURM

We based this on the SLURM setup from IndySCC, originally written by our teammate 
Caleb Lin with help from __Slurm for Dummies__, and edited it to fit our cluster. 
Munge handles authentication between the SLURM controller and compute daemons — 
the munge key must be identical on every node and permissions must be exact 
(400 on the key, munge:munge ownership) or munge fails silently and SLURM gives 
confusing errors.

The node definitions in `slurm.conf` use `SocketsPerBoard=16 CoresPerSocket=1` 
rather than the physical topology because these are VMs. SLURM sees 16 logical 
CPUs, not the actual socket/core layout of the underlying 7713.

## UID verification

After syncing users, you can verify UIDs are consistent across nodes. 
Running `srun --nodes=2 id` as exouser produced:
uid=1001(exouser) gid=1001(exouser) groups=1001(exouser),27(sudo),110(admin),127(docker),1000(ubuntu)
uid=1001(exouser) gid=1001(exouser) groups=1001(exouser),27(sudo),110(admin),127(docker),1000(ubuntu)

## Partition coverage

Right now there's no single partition covering all 4 nodes — only slimey 
(compute-1,2) and gooey (compute-3,4). Targeting all 4 nodes at once isn't 
currently possible without adding an overlapping partition. We should probably 
add one.

## A note on exceeding theoretical peak

During HPL runs we observed performance above the theoretical peak of 1.024 TFLOPS 
(32 cores × 2GHz × 16 FLOPS/cycle for AVX2/FMA). Our hypothesis: the AMD EPYC 7713 
is a 64-core chip and our VMs only use 32 of those cores. The hypervisor may allow 
active cores to boost above base clock since the idle cores leave thermal and power 
headroom available. This is hard to verify from inside the virtualization layer — 
we sampled frequencies using cpupower and /sys/devices/system/cpu/*/cpufreq/ and 
saw values above 2GHz, but can't confirm whether these reflect the physical chip 
or a virtualized frequency report.
