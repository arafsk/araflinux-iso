#!/bin/bash
#set -e

echo "What do you want to replace?"
read FIND

find . -type f -print0 | xargs -0 grep -H "$FIND" --color=always
