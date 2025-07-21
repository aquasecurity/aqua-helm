This repository contains Aqua Security Helm charts. When making changes, please follow these guidelines:

## 1. Chart version bump
- Increment the `version` field of every updated chart in its `Chart.yaml` to reflect your changes.

## 2. Update the Changelog
- Add a concise summary of your changes to `CHANGELOG.md` under the matching version entry.

## 3. Version Reference Update
- If the main `README.md` shows a default chart version example, update it.
- Likewise, update any hard‑coded example versions in installation snippets, code samples, etc.

## 4. Intra‑Chart Dependencies
Some charts depend on others within this repo. Whenever you bump one chart’s version, ensure its dependents are updated too:
- **server** → depends on **gateway**
- **kube‑enforcer** → depends on **enforcer**