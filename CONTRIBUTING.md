# Contributing to Aqua Helm Charts

## Contribution Workflow

Follow these steps to contribute changes:

1. **Fork the Repository**

   * Create your own fork of the repository and clone it to your local machine.

2. **Create a Branch and Implement Changes**

   * Create a new branch for your changes:

     ```sh
     git checkout -b <feature-or-fix-name>
     ```

   * Implement your changes to the Helm chart(s).

3. **Bump the Chart Version**

   * Open the relevant `Chart.yaml` file(s).
   * Increment the `version` field.

4. **Update the Changelog**

   * Add a summary of your changes to the `CHANGELOG.md` in the appropriate section and version entry.

5. **Update Version References**

   * Update the version in the main `README.md` if it shows a default example.
   * Update the default example version wherever relevant (such as installation instructions, code snippets, etc.).

6. **Testing**
   * Automatic tests are performed for each commit, this does not mean that you should skip manual sanity checks.
   * Ensure your changes work as intended. Please run and test the charts if possible.

7. **Commit and Push**

   * Commit your changes with a clear message including internal ticket ID if exists:

     ```sh
     git add .
     git commit -m "<short description>: <detailed explanation>"
     git push origin <branch-name>
     ```

8. **Open a Pull Request and Follow the Flow**

   * Go to the main repository and open a Pull Request from your branch.
   * Fill out the PR template and describe your changes.

* Participate in the code review process.
* Address any requested changes.
* Once approved, your PR will be merged.

## Intra-Chart Dependencies

Some Aqua Helm charts have dependencies on other charts within this repository. Please ensure dependencies are respected when making changes.

* **server** → depends on **gateway**
* **kube-enforcer** → depends on **enforcer**

When updating or testing these charts, ensure that dependent charts are installed and configured appropriately.

---

## Notes

* Always keep your branch up to date with the latest main branch.
* Please ensure your contributions follow the repository coding and documentation standards.
* More information at: [Aqua Helm Documentation](https://wiki-aquasec.atlassian.net/wiki/spaces/RD/pages/1004011857/Aqua+Helm).

Thank you for your cooperation and contribution