#!/bin/bash
#run to make sure user IDs are synced on worker nodes
PARTITION=slimey
NODE_COUNT=gooey
# 1. Define the range for human users (standard is 1000+)
MIN_UID=1000
MAX_UID=60000

# 2. Get list of users, their UIDs, and GIDs from the login node
USERS=$(awk -F: -v min=$MIN_UID -v max=$MAX_UID '$3 >= min && $3 <= max {print $1":"$3":"$4}' /etc/passwd)

echo "Starting user synchronization across all Slurm nodes..."

for USER_DATA in $USERS; do
    USERNAME=$(echo $USER_DATA | cut -d: -f1)
    UID_VAL=$(echo $USER_DATA | cut -d: -f2)
    GID_VAL=$(echo $USER_DATA | cut -d: -f3)

    echo "Syncing $USERNAME (UID: $UID_VAL)..."

    # 3. Use srun to create the group and user on all active worker nodes
    # --ntasks-per-node=1 ensures it runs once per machine
    srun -p $PARTITION -N $NODE_COUNT --ntasks-per-node=1 sudo groupadd -g $GID_VAL $USERNAME 2>/dev/null
    srun -p $PARTITION -N $NODE_COUNT --ntasks-per-node=1 sudo useradd -u $UID_VAL -g $GID_VAL -m -s /bin/bash $USERNAME 2>/dev/null
done

echo "Synchronization complete."
