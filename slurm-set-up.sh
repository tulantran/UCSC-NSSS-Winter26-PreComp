sudo apt update 
sudo apt upgrade 
sudo apt install -y openssh-server openssh-client
sudo apt install -y munge libmunge2 libmunge-dev
sudo apt install -y sshpass

munge -n | unmunge | grep STATUS

sudo /usr/sbin/mungekey
sudo chown -R munge: /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge/
sudo chmod 0700 /etc/munge/ /var/log/munge/ /var/lib/munge/
sudo chmod 0755 /run/munge/
sudo chmod 0700 /etc/munge/munge.key
sudo chown -R munge: /etc/munge/munge.key
sudo systemctl enable munge
sudo systemctl restart munge

SSH_USER="exouser"
NODES=(
  "compute-1-of-4:HAAG ELY WU LAKE SEAL FEE HALF AIDS BALI BLUR DANK"
  "compute-2-of-4:CHAR BAWD FILE WINK LOVE OAF MOCK POW GAG TEEM TAB"
  "compute-3-of-4:BEAK ROCK END OAK GLEE RACY LINE EVEN GRAY FLY FURY"
  "compute-4-of-4:DES LAY DESK URGE WHET FOND BACK KALE WORM HERB BEET"
  )

  for NODE_INFO in "${NODES[@]}"; do
    NODE="${NODE_INFO%%:*}"
    PASS="${NODE_INFO##*:}"

    echo "[*] Installing Munge on $NODE..."

    # Use sshpass + sudo -S to allow sudo with password
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$NODE" bash -c "'
        echo \"$PASS\" | sudo -S DEBIAN_FRONTEND=noninteractive apt update -qq  &&
        echo \"$PASS\" | sudo -S DEBIAN_FRONTEND=noninteractive apt install -y -qq munge libmunge2 libmunge-dev 
    '"

done

for NODE_INFO in "${NODES[@]}"; do
    NODE="${NODE_INFO%%:*}"
    PASS="${NODE_INFO##*:}"


    echo "[*] Copying Munge key to $NODE..."
    sudo cat /etc/munge/munge.key | \
        sshpass -p "$PASS" ssh "$SSH_USER@$NODE" "sudo tee /etc/munge/munge.key"
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$NODE" bash -c "'
        echo \"$PASS\" | sudo -S chown munge:munge /etc/munge/munge.key &&
        echo \"$PASS\" | sudo -S chmod 400 /etc/munge/munge.key &&
        sudo chown -R munge: /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge/ &&
        sudo chmod 0700 /etc/munge/ /var/log/munge/ /var/lib/munge/ &&
        sudo chmod 0755 /run/munge/ &&
        sudo chmod 0700 /etc/munge/munge.key &&
        sudo chown -R munge: /etc/munge/munge.key &&
        sudo systemctl enable munge &&
        sudo systemctl restart munge &&
        munge -n | unmunge | grep STATUS &&
        echo \"Munge installation and key copied on \$(hostname) at \$(date)\" | sudo tee /tmp/munge_installed.txt
    '"

    echo "[+] Munge installation marked on $NODE"
done

echo "[*] Munge installation completed on all nodes. Check /tmp/munge_installed.txt on each node for confirmation."


echo "-------------SLURM INSTALL----------------"
#SLURM install
sudo apt install -y -qq slurm-wlm libpmix-dev libpmix2 


sudo mkdir -p /var/spool/slurmctld
sudo chown slurm:slurm /var/spool/slurmctld
sudo chmod 755 /var/spool/slurmctld

sudo tee /etc/slurm/slurm.conf > /dev/null << 'EOF'
# Slurm configuration for slugalicious
ClusterName=slugalicious
SlurmUser=slurm
# Ensure 'slugalicious' resolves to your login node's internal IP in /etc/hosts
SlurmctldHost=slugalicious

StateSaveLocation=/var/spool/slurmctld
SlurmdSpoolDir=/var/spool/slurmd
SlurmctldPidFile=/run/slurmctld.pid
SlurmdPidFile=/run/slurmd.pid

# Accounting configuration
AccountingStorageType=accounting_storage/none
JobCompType=jobcomp/none

ProctrackType=proctrack/linuxproc
ReturnToService=1
SlurmctldTimeout=120
SlurmdTimeout=300
InactiveLimit=0
KillWait=30

CpuFreqGovernors=Performance

# SelectType for 16-core nodes
SelectType=select/cons_res
SelectTypeParameters=CR_Core

# Logging
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log

# Node definitions: 2 nodes for each partition, 16 cores each
# Ensure these names match the actual hostnames of your worker nodes
NodeName=compute-[1-2] CPUs=16 State=UNKNOWN
NodeName=compute-[3-4] CPUs=16 State=UNKNOWN

# Partition definitions
PartitionName=slimey Nodes=compute-[1-2] Default=YES MaxTime=INFINITE State=UP
PartitionName=gooey  Nodes=compute-[3-4] Default=NO  MaxTime=INFINITE State=UP
EOF
