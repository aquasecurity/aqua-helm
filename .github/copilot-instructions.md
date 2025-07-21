Review all pull requests for the following:

### 1. Chart Version Bump

- If a Helm chart is modified (e.g., `Chart.yaml`, `values.yaml`, `templates/`), verify that the `version` field in the corresponding `Chart.yaml` file is incremented.
- Ensure the version bump reflects the nature of the change (e.g., patch for bugfix, minor for feature, major for breaking change).

**Flag if** a chart is modified without a version update.

### 2. CHANGELOG Entry

- Confirm that `CHANGELOG.md` includes a new entry matching the updated chart version.
- Ensure the entry summarizes the changes made.

**Flag if** the changelog is missing or does not reflect the changes.

### 3. Version References in Documentation

- Check for version strings in files like `README.md` or installation examples.
- Ensure the version used in examples matches the updated chart version.

**Flag if** version examples are outdated or inconsistent.

### 4. Intra-Chart Dependencies

- If a chart with dependencies is changed, confirm that any dependent charts are also updated if needed.

  Dependency rules:
  - `server` depends on `gateway`
  - `kube-enforcer` depends on `enforcer`

**Flag if** a dependent chart is not reviewed or updated accordingly.

### 5. General Consistency

- Ensure YAML is valid and that chart structure and syntax remain consistent.
- Optionally suggest running `helm lint` or `helm template` if structural changes are made.