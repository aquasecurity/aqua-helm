This repository contains Aqua Security Helm charts. These charts require the following steps to be approved


1. Chart version bump
   * Increment the `version` field of the updated charts in the `Chart.yaml` file(s) to reflect the changes made.

2. Update the Changelog
   * A summary of changes should be added to `CHANGELOG.md` in the appropriate section and version entry.

3. Version Reference Update
   * Updating the version in the main `README.md` if it shows a default example.
   * Updating the default example version wherever relevant (such as installation instructions, code snippets, etc.).

## Intra-Chart Dependencies

Some Aqua Helm charts have dependencies on other charts within this repository. Please ensure dependencies are respected when making changes. If one chart depends on another, ensure that the dependent chart is updated accordingly.

* **server** → depends on **gateway**
* **kube-enforcer** → depends on **enforcer**