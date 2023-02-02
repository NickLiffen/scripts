# NCU at scale

## Purpose

The purpose of this script is to run [ncu](https://www.npmjs.com/package/npm-check-updates) across multiple repos simultaneously. 

## What problem is this solving?

Once a month, I have [Dependabot Version Updates](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuring-dependabot-version-updates) set to upgrade all my dependencies. Why? It keeps me on the latest and greatest, and one can only hope for better performance. It also saves you six months behind with an awful upgrade path to the newest version.

The problem with the above is when you have 25 repos, and [Dependabot Version Updates](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuring-dependabot-version-updates)  creates 7-8 upgrade PRs, it takes a VERY long time to get everything merged. 

## How does this script solve this problem?

Instead of you having to go through and merge every PR, you can run a script which will

1. Loop through all your github repos locally in the directory you provide. 
2. Check for any upgrades using [ncu](https://www.npmjs.com/package/npm-check-updates). 
3. Checks out the above upgrades into its own branch and then commits them to GitHub.
4. A PR is raised between the branch created and the `main` branch. 
5. All the created PR URLs will be added to a `prs_url.txt` in the directory in which you run the script. Which makes it easy for you to find and merge them. 

The tl;dr is it will loop through all your repos locally, upgrade all your dependencies, create PRs for you, and store the URL of the PRs locally. 

## How to run the script.

Firstly, please make sure you have the following:

[The GitHub CLI](https://cli.github.com/) installed and authed! (remember to auth)
[NCU](https://www.npmjs.com/package/npm-check-updates) installed with [NPX](https://www.npmjs.com/package/npx)  

Once you have the above installed, please follow the below. 

This script takes two flags:

| Flag | Flag Description                                               | Example                           |   |   |
|------|----------------------------------------------------------------|-----------------------------------|---|---|
| `-p` | A string which contains the root of where all your repos live  | ` -p '/Users/nickliffen/github/" |   |   |
| `-i' | A comma-separated list of directories which you want to ignore | ` -i 'folder1, folder2"` |   |   |

Some examples of how to run this script:

```bash
../ncu.sh -p '/Users/nickliffen/git/github' -i 'scripts, repo2'
```

After the script has run, you should run: `cat pr_urls.txt`, and it will give you all your PR URLs

## Questions

Just let me know!
