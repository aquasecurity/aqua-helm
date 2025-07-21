This repository contains Helm charts for Aqua Security components. When reviewing pull requests, please check the following:

- If a Helm chart is changed, ensure the `version` field in the corresponding `Chart.yaml` file has been incremented appropriately. The change should follow semantic versioning based on what was modified.

- Check that a new section has been added to `CHANGELOG.md` reflecting the updated chart version. This section should summarize the changes introduced in the pull request.

- If `README.md` or other documentation files contain hardcoded chart versions or installation examples, confirm that these versions match the newly updated chart version.

- Some charts have dependencies on others. For example, `server` depends on `gateway`, and `kube-enforcer` depends on `enforcer`. If a dependent chart was changed, check whether the other related chart should also be updated or versioned to stay compatible.

- For YAML or Helm template changes, check that the syntax is valid and consistent. You may suggest running `helm lint` if structural changes are made.

Flag any pull request that misses any of these steps or introduces inconsistencies.