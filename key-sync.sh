USERS=("tulan" "caleb") # Add all other synced usernames here

echo "Starting SSH key generation for shared home cluster..."

for user_dir in /home/*; do

    username=$(basename "$user_dir")

    if [[ -d "$user_dir" && "$username" != "ubuntu" ]]; then

    # 1. Generate keys if they don't exist
    # Use sudo -u to run as the target user
    sudo -u "$USERNAME" bash -c "
        if [ ! -f ~/.ssh/id_rsa ]; then
            mkdir -p ~/.ssh
            chmod 700 ~/.ssh
            ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N '' 
            echo 'Keys generated for $USERNAME'
        else
            echo 'Keys already exist for $USERNAME'
        fi
    "

    # 2. Add the public key to authorized_keys
    # Since home is shared, this one file works for ALL nodes
    sudo -u "$USERNAME" bash -c "
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    "

    # 3. Disable StrictHostKeyChecking (Optional but recommended for clusters)
    # This prevents 'Do you trust this host?' prompts during parallel jobs
    sudo -u "$USERNAME" bash -c "
        if [ ! -f ~/.ssh/config ]; then
            echo -e 'Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile /dev/null' > ~/.ssh/config
            chmod 600 ~/.ssh/config
        fi
    "
    fi
done

echo "SSH setup complete. Users can now move between nodes without passwords."
