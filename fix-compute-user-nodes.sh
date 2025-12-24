#!/bin/bash

# Define the nodes that are currently missing user accounts
MISSING_NODES=("compute-3-of-4" "compute-4-of-4")

# Define users and their IDs based on your login node's /etc/passwd
# Format: "username:uid:gid"
USERS=(
    "tulan:1002:1002"
    "myles:1003:1003"
    "shiloh:1004:1004"
    "brock:1005:1005"
    "andrewl:1006:1006"
    "andreww:1007:1007"
    "julien:1008:1008"
    "abhi:1009:1009"
    "holden:1010:1010"
    "caleb:1011:1011"
    "austin:1012:1012"
    "indira:1013:1013"
    "nathan:1014:1014"
)

for NODE in "${MISSING_NODES[@]}"; do
    echo "------------------------------------------"
    echo "Processing node: $NODE"
    echo "------------------------------------------"
    
    for USER_DATA in "${USERS[@]}"; do
        # Split the user data into variables
        IFS=":" read -r USERNAME UID_VAL GID_VAL <<< "$USER_DATA"
        
        echo "[*] Syncing $USERNAME (UID: $UID_VAL) to $NODE..."
        
        # 1. Ensure the group exists on the remote node first
        ssh "$NODE" "sudo groupadd -g $GID_VAL $USERNAME -f"
        
        # 2. Create the user entry in /etc/passwd
        # -u: specifies the UID to match the login node
        # -g: specifies the primary GID
        # -M: do NOT create home directory (it is already on the Manila share)
        # -s: sets the login shell to bash
        ssh "$NODE" "sudo useradd -u $UID_VAL -g $GID_VAL -M -s /bin/bash $USERNAME 2>/dev/null"
        
        if [ $? -eq 0 ]; then
            echo "[+] Success: $USERNAME entry created."
        else
            echo "[!] Note: $USERNAME already exists or was skipped."
        fi
    done
done

echo "------------------------------------------"
echo "Sync Complete. Verifying compute-3-of-4..."
ssh compute-3-of-4 "tail -n 13 /etc/passwd"