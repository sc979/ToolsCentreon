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

The "deployPR.sh" will ~backup~ and deploy files from a PR using :
- a file list like "filesLocation.txt",
- the sha1 of the PR.

All the files listed in "filesLocation.txt" will be downloaded directly from the Centreon's official github public repositories.

You can find the sha1 by clicking on the "view file" -> raw file" button of one file of the target PR.
ie : in `https://raw.githubusercontent.com/centreon/centreon/dc98ab9afdfe2bdad0c8918a327ac28e8287cb6a/cron/centAcl-Func.php`
`dc98ab9afdfe2bdad0c8918a327ac28e8287cb6a` is the sha1 of the last commit in the PR.

**Files to deploy**

To get the list of the files, you can use the diff-tree command :
eg : `$ git diff-tree --no-commit-id --name-only -r {commitBeforeChanges}..{lastCommitOfThePullRequest} > filesLocation.txt`


**Feedbacks**

If you experience bugs or have ideas/feedback, feel free to contact me on "schapron@centreon.com".

**Todo**

- Validate that everything work fine.
- Concatenate the two scripts (backup/revert) into a single script.
- Automate the "filesLocation.txt" generation.
- Integrate this script in Centreon's repository to make it available to everyone.
