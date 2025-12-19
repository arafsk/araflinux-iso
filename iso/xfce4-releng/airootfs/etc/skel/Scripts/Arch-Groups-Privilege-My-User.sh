#!/bin/bash

USERNAME="arafsk"

# Arch-relevant groups for common privileges
groups=(wheel audio video disk optical storage lp scanner network)

for group in "${groups[@]}"; do
    if getent group "$group" > /dev/null; then
        sudo usermod -aG "$group" "$USERNAME" && \
            echo "Added $USERNAME to group: $group" || \
            echo "⚠️  Failed to add $USERNAME to group: $group"
    else
        echo "⛔ Group '$group' does not exist on this system. Skipping."
    fi
done

echo -e "\n✅ Done. You may need to log out for see the effect."
