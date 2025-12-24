#!/bin/bash
# Run with: sudo bash ssh-gen-fix-perms.sh

for user_dir in /home/*; do
    USERNAME=$(basename "$user_dir")

    # Skip system/admin accounts
    if [[ "$USERNAME" != "ubuntu" && "$USERNAME" != "exouser" && "$USERNAME" != "root" ]]; then
        echo "Processing $USERNAME..."

        # 1. Create .ssh directory if missing
        sudo -u "$USERNAME" mkdir -p "$user_dir/.ssh"
        
        # 2. Generate the key (if it doesn't exist)
        if [ ! -f "$user_dir/.ssh/id_rsa" ]; then
            sudo -u "$USERNAME" ssh-keygen -t rsa -b 4096 -f "$user_dir/.ssh/id_rsa" -N ""
        fi

        # 3. Self-authorize (add public key to authorized_keys)
        sudo -u "$USERNAME" bash -c "cat $user_dir/.ssh/id_rsa.pub >> $user_dir/.ssh/authorized_keys"

        # 4. Disable host checking for cluster nodes
        sudo -u "$USERNAME" bash -c "echo -e 'Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile /dev/null' > $user_dir/.ssh/config"

        # 5. Set perfect permissions
        sudo chown -R "$USERNAME:$USERNAME" "$user_dir/.ssh"
        sudo chmod 700 "$user_dir/.ssh"
        sudo chmod 600 "$user_dir/.ssh/"*
        
        echo "[+] $USERNAME is now cluster-ready."
    fi
done