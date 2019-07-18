# ToolsCentreon/deployPR

Licensed under the Apache License, Version 2.0 (the "License");
author:sc979
https://github.com/sc979

This is a Readme file to help you use these scripts


**Notice**

I'm doing this out of my work time.

As almost all scripts, it needs to be executable :
`$ chmod +x {filename}`

**Caution**

These scripts are still in a work in progress / draft state, to help customers and support team, deploy PR on customers' environnements.

**Deploy Script**

The "deployLdapSynchro.sh" will backup and deploy files from a PR using :
- a file list like "filesLocation.txt",
- the sha1 of the PR,
- the location of your Centreon.

All the files listed in "filesLocation.txt" will be downloaded directly from the Centreon's official github public repositories.

You can find the sha1 by clicking on the "view file" -> raw file" button of one file of the target PR.
ie : in `https://raw.githubusercontent.com/centreon/centreon/dc98ab9afdfe2bdad0c8918a327ac28e8287cb6a/cron/centAcl-Func.php`
`dc98ab9afdfe2bdad0c8918a327ac28e8287cb6a` is the sha1 for all files in the PR.

**Files to deploy**

To get the list of the files, you can use the diff-tree command :
eg : `$ git diff-tree --no-commit-id --name-only -r {commitBeforeChanges}..{lastCommitOfThePullRequest} > filesLocation.txt`

**Revert Script**

A script to revert to previous state is available too.
It uses the "filesLocation.txt" files to delete modified files and restore backuped files
"revertChanges.sh"

**Feedbacks**

If you experience bugs or have ideas/feedback, feel free to contact me on "schapron@centreon.com".

**Todo**

- Validate that everything work fine.
- Improve the scripts to require less steps.
- Concatenate the two scripts (backup/revert) into a single script.
- Automate the "filesLocation.txt" generation.
- Integrate this script on Centreon's repository to make it available to everyone.
