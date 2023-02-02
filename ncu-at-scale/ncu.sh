#!/usr/bin/env bash

set -e

####
# This script will upgrade all dependencies in a directory
# It will also create a branch, commit, push and create a PR
# It will also ignore any directories you pass in
# An example of how you can use this script is:
# ./ncu.sh -p /Users/username/Projects -i "project1,project2"
# the -p flag is for the path and the -i flag is for the ignore list. The ignore list is optional.
####

# Getting the flags from the command line
while getopts p:i: flag; do
    case "${flag}" in
    p) path=${OPTARG} ;;
    i) ignore=${OPTARG} ;;
    *)
        echo "usage: $0 [-p] [-i]" >&2
        exit 1
        ;;
    esac
done

echo "You have passed in the followig path: $path"
echo "You would like to ignore the following directories: $ignore"

FILE="package.json"
YARN_LOCK="yarn.lock"

# Checking and making sure the path exists
if [[ -d "$path" ]]; then
    echo "Directory $path exists."
else
    echo "Error: Directory $path does not exist."
    exit 1
fi

# Checking and making sure the path isn't empty
if [ -z "$(ls -A "$path")" ]; then
    echo "We found $path is empty, so we can't continue. There is nothing to upgrade."
    exit 1
else
    echo "$path is not empty, so we can continue."
fi

cd "$path"

# Generate random number
random_number=$RANDOM
NUMBER=$(((random_number % 100) + 1))

# A function that checks if a drectory is in the ignore list
function is_ignored {
    local dir=$1
    local ignore=$2
    local IFS=','
    read -ra ADDR <<<"$ignore"
    for i in "${ADDR[@]}"; do
        i=$(echo "$i" | sed 's/[, ]//g')
        if [ "$i" == "$dir" ]; then
            echo "We found $dir in the ignore list, so we will skip it."
            return 0
        fi
    done
    echo "We did not find $dir in the ignore list, so we will continue."
    return 1
}

# A function that creates a file and appends a value to the end of the file
function create_file {
    local file=$1
    local value=$2
    if [ -f "$file" ]; then
        echo "$file exists!"
    else
        echo "$file does not exist! Creating it now."
        touch "$file"
    fi
    echo "$value" >>"$file"
}

# A command that runs the upgrade process
function runUpgradeProcess {
    for d in */; do
        [ -L "${d%/}" ] && continue

        is_ignored "${d%/}" "$ignore" && continue

        echo "Upgrading Dependencies in: $d"
        echo "${d%/}"
        cd "$d"

        git checkout main
        git pull --all
        git fetch --all

         # Check if package.json exists and also if there is a .git directory 
        if [[ -f "$FILE" ]] && [[ -d ".git" ]]; then
            echo "A $FILE exists and we found a .git directory. We can update dependencies."
        else
            echo "A $FILE does not exists. We can't update dependencies if there is no $FILE."
            break
        fi

        git checkout -b ft/deps-upgrade-$NUMBER
        npx npm-check-updates -u

        if [[ -f "$YARN_LOCK" ]]; then
            yarn install
        else
            npm install
        fi

        git add .
        git commit -m "chore(deps): upgrade dependencies"
        git push --set-upstream origin ft/deps-upgrade-$NUMBER

        gh pr create --title "chore(deps): upgrade dependencies" --body "This PR upgrades dependencies" --base main --head ft/deps-upgrade-$NUMBER

        sleep 5
        PR_URL=$(gh pr view --json url --jq '.url')
        cd ..
        create_file ./pr_urls.txt "$PR_URL"
    done
}

runUpgradeProcess
